-- RevenueCat Subscription Tables
-- 订阅状态表和 Webhook 日志表
-- 
-- Key Concepts (from RevenueCat):
-- - Entitlements: Users are "entitled" to access levels (plus, pro)
-- - tier maps to entitlements in code (see subscription.ts)

-- ============================================
-- 1. 用户订阅表 (User Subscriptions)
-- ============================================
CREATE TABLE user_subscriptions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,

  -- 订阅状态
  -- tier: 订阅等级，映射到 entitlements
  tier TEXT NOT NULL DEFAULT 'free' CHECK (tier IN ('free', 'plus', 'pro')),
  -- status: 包含 'paused' 状态 (Google Play 支持暂停订阅)
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'expired', 'grace_period', 'cancelled', 'paused')),

  -- RevenueCat 信息
  revenuecat_app_user_id TEXT,
  original_transaction_id TEXT,
  product_id TEXT,
  platform TEXT CHECK (platform IN ('apple', 'google')),
  -- environment: 区分 sandbox 和 production
  environment TEXT CHECK (environment IN ('SANDBOX', 'PRODUCTION')),

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
CREATE INDEX idx_user_subscriptions_tier ON user_subscriptions(tier);

-- 创建或更新 updated_at 触发器函数 (如果不存在)
CREATE OR REPLACE FUNCTION update_subscription_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 创建更新时间触发器
CREATE TRIGGER update_user_subscriptions_updated_at
  BEFORE UPDATE ON user_subscriptions
  FOR EACH ROW EXECUTE FUNCTION update_subscription_updated_at();

-- ============================================
-- 2. RLS 策略 (Row Level Security)
-- ============================================
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;

-- 用户只能读取自己的订阅
CREATE POLICY "Users can view own subscription"
  ON user_subscriptions FOR SELECT
  USING (auth.uid() = user_id);

-- 只允许后端服务更新（通过 service_role key）
-- 注意：使用 service_role key 时会绕过 RLS，所以这个策略是额外的安全层
CREATE POLICY "Service can manage subscriptions"
  ON user_subscriptions FOR ALL
  USING (auth.jwt() ->> 'role' = 'service_role');

-- ============================================
-- 3. Webhook 日志表 (可选，用于审计)
-- ============================================
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

-- Webhook 日志表不启用 RLS（只有后端服务访问）
ALTER TABLE subscription_webhook_logs ENABLE ROW LEVEL SECURITY;

-- 只允许服务角色访问日志
CREATE POLICY "Service can manage webhook logs"
  ON subscription_webhook_logs FOR ALL
  USING (auth.jwt() ->> 'role' = 'service_role');
