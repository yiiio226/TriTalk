# RevenueCat Backend Implementation

[Return to Main Documentation](../../docs/revenuecat_subscription.md)

## 1. 后端实现

### 1.1 数据库设计 (Supabase)

#### 1.1.1 用户订阅表

```sql
-- 创建订阅状态表
CREATE TABLE user_subscriptions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,

  -- 订阅状态
  tier TEXT NOT NULL DEFAULT 'free' CHECK (tier IN ('free', 'plus', 'pro')),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'expired', 'grace_period', 'cancelled')),

  -- RevenueCat 信息
  revenuecat_app_user_id TEXT,
  original_transaction_id TEXT,
  product_id TEXT,
  platform TEXT CHECK (platform IN ('apple', 'google')),

  -- 时间戳
  purchased_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,

  -- 元信息
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_user_subscriptions_user_id ON user_subscriptions(user_id);
CREATE INDEX idx_user_subscriptions_expires_at ON user_subscriptions(expires_at);
CREATE INDEX idx_user_subscriptions_status ON user_subscriptions(status);

-- 更新时间触发器
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_subscriptions_updated_at
  BEFORE UPDATE ON user_subscriptions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- RLS 策略
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;

-- 用户只能读取自己的订阅
CREATE POLICY "Users can view own subscription"
  ON user_subscriptions FOR SELECT
  USING (auth.uid() = user_id);

-- 只允许后端服务更新（通过 service_role key）
CREATE POLICY "Service can manage subscriptions"
  ON user_subscriptions FOR ALL
  USING (auth.jwt() ->> 'role' = 'service_role');
```

#### 设计说明：updated_at 触发器与自动清理的关系

上述 SQL 中有两个重要的机制需要理解：

**1. `updated_at` 触发器（Trigger）**

这是一个**被动的审计机制**，每当 `user_subscriptions` 表有 UPDATE 操作时，自动将 `updated_at` 设为当前时间。

**作用**：

- 追踪记录最后一次修改时间，方便调试
- 数据一致性检查（如：找出过期但长时间未更新的记录）
- 排序和筛选（如：查看最近更新的订阅）

**2. 自动清理（见 1.4 节）与触发器的协作**

两者是**互补关系**，处理不同场景：

```
正常流程（Webhook 正常工作）：
───────────────────────────────────────────────────────────────────►
1月1日: 用户购买 Pro
        └─→ RevenueCat 发 INITIAL_PURCHASE webhook
            └─→ 后端写入: tier='pro', expires_at='2月1日'
                └─→ Trigger 自动设置: updated_at='1月1日'

2月1日: 订阅过期
        └─→ RevenueCat 发 EXPIRATION webhook ← 理想情况
            └─→ 后端写入: tier='free', status='expired'
                └─→ Trigger 自动设置: updated_at='2月1日'


异常流程（Webhook 失败时，自动清理兜底）：
───────────────────────────────────────────────────────────────────►
2月1日: 订阅过期
        └─→ RevenueCat 发 EXPIRATION webhook
            └─→ ❌ 网络问题，Webhook 失败！
                └─→ 数据库里用户仍然是 tier='pro' (已过期)

2月1日 01:00: 自动清理 Cron 运行（1.4 节）← 保底机制
        └─→ 查询: expires_at < NOW() AND tier != 'free'
            └─→ 找到过期用户，更新: tier='free'
                └─→ Trigger 自动设置: updated_at='2月1日 01:00'
```

| 组件                 | 类型     | 作用                                        |
| -------------------- | -------- | ------------------------------------------- |
| `updated_at` Trigger | 被动机制 | 自动记录"什么时候动过这条数据"              |
| 自动清理             | 主动机制 | 每小时检查一遍，清理 Webhook 遗漏的过期订阅 |

#### 1.1.2 Webhook 日志表（可选，用于审计）

```sql
-- Webhook 事件日志
CREATE TABLE subscription_webhook_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  event_type TEXT NOT NULL,
  event_id TEXT,
  app_user_id TEXT,
  original_transaction_id TEXT,
  product_id TEXT,
  payload JSONB,
  processed_at TIMESTAMPTZ DEFAULT NOW(),
  success BOOLEAN DEFAULT true,
  error_message TEXT
);

-- 索引
CREATE INDEX idx_webhook_logs_event_type ON subscription_webhook_logs(event_type);
CREATE INDEX idx_webhook_logs_app_user_id ON subscription_webhook_logs(app_user_id);
CREATE INDEX idx_webhook_logs_processed_at ON subscription_webhook_logs(processed_at);
```

### 1.2 Webhook 处理

#### 1.2.1 RevenueCat Webhook 配置

在 RevenueCat Dashboard 中配置 Webhook：

1. 进入 Project Settings → Integrations → Webhooks
2. 添加新的 Webhook URL: `https://your-backend.workers.dev/webhook/revenuecat`
3. 配置 Authorization Header（Bearer Token）
4. 选择需要的事件类型：
   - `INITIAL_PURCHASE`: 首次购买
   - `RENEWAL`: 续订
   - `CANCELLATION`: 取消
   - `UNCANCELLATION`: 取消后恢复
   - `EXPIRATION`: 过期
   - `BILLING_ISSUE`: 账单问题
   - `PRODUCT_CHANGE`: 产品变更（升级/降级）
   - `TRANSFER`: 用户转移
   - `REFUND`: 退款（用户申请退款成功）

#### 1.2.2 Webhook 处理代码

```typescript
// backend/src/services/subscription.ts

import { SupabaseClient } from "@supabase/supabase-js";

// RevenueCat Webhook 事件类型
type RevenueCatEventType =
  | "INITIAL_PURCHASE"
  | "RENEWAL"
  | "CANCELLATION"
  | "UNCANCELLATION"
  | "EXPIRATION"
  | "BILLING_ISSUE"
  | "PRODUCT_CHANGE"
  | "TRANSFER"
  | "REFUND"; // 退款事件

interface RevenueCatWebhookEvent {
  event: {
    type: RevenueCatEventType;
    id: string;
    app_user_id: string;
    original_app_user_id?: string;
    product_id: string;
    period_type?: string;
    purchased_at_ms?: number;
    expiration_at_ms?: number;
    environment?: string;
    store?: string;
    original_transaction_id?: string;
  };
  api_version: string;
}

// 产品 ID 到订阅等级的映射
const PRODUCT_TO_TIER: Record<string, "plus" | "pro"> = {
  tritalkplusmonthly: "plus",
  tritalkplusyearly: "plus",
  tritalkpromonthly: "pro",
  tritalkproyearly: "pro",
};

/**
 * 从 product_id 提取基础产品 ID
 *
 * Google Play 的 product_id 格式为 subscriptionId:basePlanId
 * 例如: tritalkplusmonthly:monthly-autorenewing
 *
 * Apple App Store 的 product_id 格式为纯 productId
 * 例如: tritalkplusmonthly
 *
 * 此函数统一提取基础的 subscriptionId/productId
 */
function extractBaseProductId(productId: string): string {
  // 如果包含冒号，说明是 Google Play 格式，取冒号前的部分
  const colonIndex = productId.indexOf(":");
  if (colonIndex !== -1) {
    return productId.substring(0, colonIndex);
  }
  // Apple 格式，直接返回
  return productId;
}

export async function handleRevenueCatWebhook(
  supabase: SupabaseClient,
  payload: RevenueCatWebhookEvent,
): Promise<{ success: boolean; error?: string }> {
  const { event } = payload;
  const {
    type,
    app_user_id,
    product_id,
    expiration_at_ms,
    original_transaction_id,
    store,
  } = event;

  console.log(`Processing RevenueCat event: ${type} for user: ${app_user_id}`);

  try {
    // 提取基础产品 ID（兼容 Apple 和 Google Play 格式）
    const baseProductId = extractBaseProductId(product_id);
    const tier = PRODUCT_TO_TIER[baseProductId] || "free";
    const platform =
      store === "APP_STORE"
        ? "apple"
        : store === "PLAY_STORE"
          ? "google"
          : null;
    const expiresAt = expiration_at_ms
      ? new Date(expiration_at_ms).toISOString()
      : null;

    switch (type) {
      case "INITIAL_PURCHASE":
      case "RENEWAL":
      case "UNCANCELLATION":
        await upsertSubscription(supabase, {
          userId: app_user_id,
          tier,
          status: "active",
          productId: product_id,
          platform,
          expiresAt,
          originalTransactionId: original_transaction_id,
          purchasedAt: new Date().toISOString(),
        });
        break;

      case "CANCELLATION":
        // 用户取消但仍在有效期内
        await updateSubscriptionStatus(supabase, app_user_id, "cancelled");
        break;

      case "EXPIRATION":
        // 订阅已过期
        await updateSubscriptionToFree(supabase, app_user_id);
        break;

      case "BILLING_ISSUE":
        // 账单问题，进入宽限期
        await updateSubscriptionStatus(supabase, app_user_id, "grace_period");
        break;

      case "PRODUCT_CHANGE":
        // 升级或降级
        await upsertSubscription(supabase, {
          userId: app_user_id,
          tier,
          status: "active",
          productId: product_id,
          platform,
          expiresAt,
          originalTransactionId: original_transaction_id,
        });
        break;

      case "TRANSFER":
        // 用户转移，更新关联
        const newUserId = event.app_user_id;
        const oldUserId = event.original_app_user_id;
        if (oldUserId && newUserId !== oldUserId) {
          await transferSubscription(supabase, oldUserId, newUserId);
        }
        break;

      case "REFUND":
        // 用户申请退款成功，立即撤销订阅权益
        await updateSubscriptionToFree(supabase, app_user_id);
        console.log(`Subscription refunded for user: ${app_user_id}`);
        break;
    }

    // 记录 webhook 日志
    await logWebhookEvent(supabase, event, true);

    return { success: true };
  } catch (error) {
    console.error("Webhook processing error:", error);
    await logWebhookEvent(supabase, event, false, (error as Error).message);
    return { success: false, error: (error as Error).message };
  }
}

interface SubscriptionData {
  userId: string;
  tier: "free" | "plus" | "pro";
  status: "active" | "expired" | "grace_period" | "cancelled";
  productId?: string;
  platform?: "apple" | "google" | null;
  expiresAt?: string | null;
  originalTransactionId?: string;
  purchasedAt?: string;
}

async function upsertSubscription(
  supabase: SupabaseClient,
  data: SubscriptionData,
) {
  const { error } = await supabase.from("user_subscriptions").upsert(
    {
      user_id: data.userId,
      tier: data.tier,
      status: data.status,
      product_id: data.productId,
      platform: data.platform,
      expires_at: data.expiresAt,
      original_transaction_id: data.originalTransactionId,
      purchased_at: data.purchasedAt,
      revenuecat_app_user_id: data.userId,
    },
    { onConflict: "user_id" },
  );

  if (error) throw error;
}

async function updateSubscriptionStatus(
  supabase: SupabaseClient,
  userId: string,
  status: string,
) {
  const { error } = await supabase
    .from("user_subscriptions")
    .update({
      status,
      cancelled_at: status === "cancelled" ? new Date().toISOString() : null,
    })
    .eq("user_id", userId);

  if (error) throw error;
}

async function updateSubscriptionToFree(
  supabase: SupabaseClient,
  userId: string,
) {
  const { error } = await supabase
    .from("user_subscriptions")
    .update({
      tier: "free",
      status: "expired",
      expires_at: new Date().toISOString(),
    })
    .eq("user_id", userId);

  if (error) throw error;
}

async function transferSubscription(
  supabase: SupabaseClient,
  oldUserId: string,
  newUserId: string,
) {
  const { error } = await supabase
    .from("user_subscriptions")
    .update({ user_id: newUserId })
    .eq("user_id", oldUserId);

  if (error) throw error;
}

async function logWebhookEvent(
  supabase: SupabaseClient,
  event: RevenueCatWebhookEvent["event"],
  success: boolean,
  errorMessage?: string,
) {
  await supabase.from("subscription_webhook_logs").insert({
    event_type: event.type,
    event_id: event.id,
    app_user_id: event.app_user_id,
    original_transaction_id: event.original_transaction_id,
    product_id: event.product_id,
    payload: event,
    success,
    error_message: errorMessage,
  });
}
```

#### 1.2.3 Webhook 路由

```typescript
// backend/src/server.ts (新增路由)

import { handleRevenueCatWebhook } from "./services/subscription";

// RevenueCat Webhook 端点
app.post("/webhook/revenuecat", async (c) => {
  // 验证 webhook 签名
  const authHeader = c.req.header("Authorization");
  const expectedToken = c.env.REVENUECAT_WEBHOOK_SECRET;

  if (!authHeader || authHeader !== `Bearer ${expectedToken}`) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  try {
    const payload = await c.req.json();

    // 使用 service role key 创建 Supabase 客户端
    const supabase = createClient(
      c.env.SUPABASE_URL,
      c.env.SUPABASE_SERVICE_ROLE_KEY,
    );

    const result = await handleRevenueCatWebhook(supabase, payload);

    if (result.success) {
      return c.json({ success: true });
    } else {
      return c.json({ success: false, error: result.error }, 500);
    }
  } catch (error) {
    console.error("Webhook error:", error);
    return c.json({ error: "Internal server error" }, 500);
  }
});
```

### 1.3 订阅状态 API

```typescript
// GET /subscription/status - 获取当前用户订阅状态
app.get("/subscription/status", authMiddleware, async (c) => {
  const user = c.get("user");
  const supabase = createSupabaseClient(
    c.env,
    c.req.header("Authorization")!.split(" ")[1],
  );

  const { data, error } = await supabase
    .from("user_subscriptions")
    .select("tier, status, expires_at, product_id")
    .eq("user_id", user.id)
    .single();

  if (error && error.code !== "PGRST116") {
    // PGRST116 = no rows found
    return c.json({ error: error.message }, 500);
  }

  return c.json({
    tier: data?.tier || "free",
    status: data?.status || "active",
    expires_at: data?.expires_at,
    product_id: data?.product_id,
  });
});
```

### 1.4 自动清理过期订阅

#### 1.4.1 Cloudflare Cron Trigger

```typescript
// wrangler.toml
[triggers]
crons = ["0 * * * *"]  # 每小时运行一次

// backend/src/scheduled.ts
export default {
  async scheduled(event: ScheduledEvent, env: Env, ctx: ExecutionContext) {
    ctx.waitUntil(cleanupExpiredSubscriptions(env));
  },
};

async function cleanupExpiredSubscriptions(env: Env) {
  const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY);

  // 查找已过期但状态未更新的订阅
  const { data: expiredSubscriptions, error } = await supabase
    .from('user_subscriptions')
    .select('id, user_id')
    .lt('expires_at', new Date().toISOString())
    .neq('tier', 'free')
    .in('status', ['active', 'grace_period']);

  if (error) {
    console.error('Failed to fetch expired subscriptions:', error);
    return;
  }

  if (!expiredSubscriptions || expiredSubscriptions.length === 0) {
    console.log('No expired subscriptions to clean up');
    return;
  }

  console.log(`Found ${expiredSubscriptions.length} expired subscriptions`);

  // 批量更新为 free
  for (const sub of expiredSubscriptions) {
    const { error: updateError } = await supabase
      .from('user_subscriptions')
      .update({
        tier: 'free',
        status: 'expired',
      })
      .eq('id', sub.id);

    if (updateError) {
      console.error(`Failed to update subscription ${sub.id}:`, updateError);
    } else {
      console.log(`Cleaned up subscription for user ${sub.user_id}`);
    }
  }
}
```

## 2. 环境变量配置 (Backend)

```toml
[vars]
# ... 其他配置

[env.production.vars]
# RevenueCat Webhook Secret
REVENUECAT_WEBHOOK_SECRET = "your_webhook_secret"
# Supabase Service Role Key (用于 webhook 处理)
SUPABASE_SERVICE_ROLE_KEY = "your_service_role_key"
```

## 3. Webhook 测试

- [ ] INITIAL_PURCHASE 事件处理
- [ ] RENEWAL 事件处理
- [ ] CANCELLATION 事件处理
- [ ] EXPIRATION 事件处理
- [ ] BILLING_ISSUE 事件处理
- [ ] PRODUCT_CHANGE 事件处理

## 4. 后端测试

- [ ] Webhook 认证验证
- [ ] 数据库更新正确性
- [ ] 过期清理 Cron 任务
- [ ] API 响应正确性

## 5. 安全考虑

1. **Webhook 验证**: 必须验证 RevenueCat webhook 签名
2. **服务器端验证**: 关键权限检查在后端进行，不仅依赖客户端
3. **敏感数据**: API Keys 不要硬编码，使用环境变量
4. **RLS 策略**: 确保用户只能访问自己的订阅数据
5. **日志脱敏**: 不记录敏感的交易详情
