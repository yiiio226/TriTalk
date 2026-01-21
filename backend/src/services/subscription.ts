/**
 * RevenueCat Subscription Service
 *
 * Handles RevenueCat webhook processing and subscription management.
 * RevenueCat Webhook 处理和订阅管理服务。
 *
 * Key Concepts (from RevenueCat Skill):
 * - Entitlements: A level of access that users are "entitled" to
 * - Offerings: The set of products available to users
 * - CustomerInfo: Central object containing subscription data
 */

import { SupabaseClient } from "@supabase/supabase-js";

// ============================================
// Types
// ============================================

/**
 * RevenueCat Webhook 事件类型
 * @see https://www.revenuecat.com/docs/integrations/webhooks
 */
export type RevenueCatEventType =
  | "INITIAL_PURCHASE" // 首次购买
  | "RENEWAL" // 续订
  | "CANCELLATION" // 取消（仍在有效期内）
  | "UNCANCELLATION" // 取消后恢复
  | "EXPIRATION" // 过期
  | "BILLING_ISSUE" // 账单问题
  | "PRODUCT_CHANGE" // 升级/降级
  | "TRANSFER" // 用户转移
  | "REFUND" // 退款
  | "SUBSCRIBER_ALIAS" // 用户关联（匿名→登录）
  | "SUBSCRIPTION_PAUSED" // 订阅暂停（Google Play）
  | "SUBSCRIPTION_EXTENDED" // 订阅延长
  | "TEST"; // 测试事件

/** 订阅等级 */
export type SubscriptionTier = "free" | "plus" | "pro";

/** 订阅状态 */
export type SubscriptionStatus =
  | "active"
  | "expired"
  | "grace_period"
  | "cancelled"
  | "paused"; // Google Play 支持暂停

/** 平台类型 */
export type Platform = "apple" | "google";

/** 环境类型 */
export type Environment = "SANDBOX" | "PRODUCTION";

/**
 * Entitlement (权益) 定义
 * RevenueCat 的核心概念，表示用户有权访问的功能级别
 */
export type EntitlementId = "plus" | "pro";

/**
 * RevenueCat Webhook 事件结构
 * 完整的 webhook payload 结构
 */
export interface RevenueCatWebhookEvent {
  event: {
    type: RevenueCatEventType;
    id: string;
    app_user_id: string;
    original_app_user_id?: string;
    aliases?: string[]; // 用户别名列表
    product_id: string;
    entitlement_ids?: string[]; // 关联的 entitlement IDs
    period_type?: string; // "NORMAL", "TRIAL", "INTRO"
    purchased_at_ms?: number;
    expiration_at_ms?: number;
    environment?: Environment;
    store?: string; // "APP_STORE", "PLAY_STORE", "STRIPE", etc.
    original_transaction_id?: string;
    is_family_share?: boolean;
    country_code?: string;
    currency?: string;
    price_in_purchased_currency?: number;
  };
  api_version: string;
}

/** 订阅数据 */
export interface SubscriptionData {
  userId: string;
  tier: SubscriptionTier;
  status: SubscriptionStatus;
  productId?: string;
  platform?: Platform | null;
  expiresAt?: string | null;
  originalTransactionId?: string;
  purchasedAt?: string;
  entitlementId?: EntitlementId;
  environment?: Environment;
}

/**
 * 用户订阅信息（从数据库读取）
 * 与 RevenueCat CustomerInfo 的简化版本对应
 */
export interface UserSubscription {
  tier: SubscriptionTier;
  status: SubscriptionStatus;
  expires_at: string | null;
  product_id: string | null;
  /** 活跃的 entitlement，前端可直接检查 */
  active_entitlements: EntitlementId[];
  /** 是否有活跃的付费订阅 */
  is_premium: boolean;
}

// ============================================
// Constants
// ============================================

/**
 * 产品 ID 到订阅等级的映射
 * Product ID to subscription tier mapping
 */
export const PRODUCT_TO_TIER: Record<string, SubscriptionTier> = {
  // 月度订阅
  tritalkplusmonthly: "plus",
  tritalkpromonthly: "pro",
  // 年度订阅
  tritalkplusyearly: "plus",
  tritalkproyearly: "pro",
};

// ============================================
// Helper Functions
// ============================================

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
export function extractBaseProductId(productId: string): string {
  // 如果包含冒号，说明是 Google Play 格式，取冒号前的部分
  const colonIndex = productId.indexOf(":");
  if (colonIndex !== -1) {
    return productId.substring(0, colonIndex);
  }
  // Apple 格式，直接返回
  return productId;
}

/**
 * 从产品 ID 获取订阅等级
 */
export function getTierFromProductId(productId: string): SubscriptionTier {
  const baseProductId = extractBaseProductId(productId);
  return PRODUCT_TO_TIER[baseProductId] || "free";
}

/**
 * 从 store 字符串获取平台类型
 */
export function getPlatformFromStore(store?: string): Platform | null {
  switch (store) {
    case "APP_STORE":
      return "apple";
    case "PLAY_STORE":
      return "google";
    default:
      return null;
  }
}

// ============================================
// Database Operations
// ============================================

/**
 * 插入或更新订阅记录
 */
async function upsertSubscription(
  supabase: SupabaseClient<any, string, any>,
  data: SubscriptionData,
): Promise<void> {
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

  if (error) {
    console.error("Failed to upsert subscription:", error);
    throw error;
  }
}

/**
 * 更新订阅状态
 */
async function updateSubscriptionStatus(
  supabase: SupabaseClient<any, string, any>,
  userId: string,
  status: SubscriptionStatus,
): Promise<void> {
  const updateData: Record<string, any> = { status };

  // 如果是取消状态，记录取消时间
  if (status === "cancelled") {
    updateData.cancelled_at = new Date().toISOString();
  }

  const { error } = await supabase
    .from("user_subscriptions")
    .update(updateData)
    .eq("user_id", userId);

  if (error) {
    console.error("Failed to update subscription status:", error);
    throw error;
  }
}

/**
 * 将订阅重置为免费用户
 */
async function updateSubscriptionToFree(
  supabase: SupabaseClient<any, string, any>,
  userId: string,
): Promise<void> {
  const { error } = await supabase
    .from("user_subscriptions")
    .update({
      tier: "free",
      status: "expired",
      expires_at: new Date().toISOString(),
    })
    .eq("user_id", userId);

  if (error) {
    console.error("Failed to update subscription to free:", error);
    throw error;
  }
}

/**
 * 转移订阅（用户账号迁移）
 */
async function transferSubscription(
  supabase: SupabaseClient<any, string, any>,
  oldUserId: string,
  newUserId: string,
): Promise<void> {
  const { error } = await supabase
    .from("user_subscriptions")
    .update({ user_id: newUserId })
    .eq("user_id", oldUserId);

  if (error) {
    console.error("Failed to transfer subscription:", error);
    throw error;
  }
}

/**
 * 记录 Webhook 事件日志
 */
async function logWebhookEvent(
  supabase: SupabaseClient<any, string, any>,
  event: RevenueCatWebhookEvent["event"],
  success: boolean,
  errorMessage?: string,
): Promise<void> {
  try {
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
  } catch (logError) {
    // 日志记录失败不应该影响主流程
    console.error("Failed to log webhook event:", logError);
  }
}

// ============================================
// Main Webhook Handler
// ============================================

/**
 * 处理 RevenueCat Webhook 事件
 *
 * @param supabase - Supabase client with service role key
 * @param payload - RevenueCat webhook payload
 * @returns Result with success status and optional error
 */
export async function handleRevenueCatWebhook(
  supabase: SupabaseClient<any, string, any>,
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

  // 忽略测试事件
  if (type === "TEST") {
    console.log("Received TEST event, skipping processing");
    await logWebhookEvent(supabase, event, true);
    return { success: true };
  }

  try {
    // 提取基础产品 ID（兼容 Apple 和 Google Play 格式）
    const tier = getTierFromProductId(product_id);
    const platform = getPlatformFromStore(store);
    const expiresAt = expiration_at_ms
      ? new Date(expiration_at_ms).toISOString()
      : null;

    switch (type) {
      case "INITIAL_PURCHASE":
      case "RENEWAL":
      case "UNCANCELLATION":
        // 新购买、续订、取消后恢复 - 设置为活跃订阅
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
        console.log(
          `Subscription activated: ${type} for user ${app_user_id}, tier: ${tier}`,
        );
        break;

      case "CANCELLATION":
        // 用户取消但仍在有效期内
        await updateSubscriptionStatus(supabase, app_user_id, "cancelled");
        console.log(`Subscription cancelled for user: ${app_user_id}`);
        break;

      case "EXPIRATION":
        // 订阅已过期
        await updateSubscriptionToFree(supabase, app_user_id);
        console.log(`Subscription expired for user: ${app_user_id}`);
        break;

      case "BILLING_ISSUE":
        // 账单问题，进入宽限期
        await updateSubscriptionStatus(supabase, app_user_id, "grace_period");
        console.log(
          `Subscription billing issue for user: ${app_user_id}, entering grace period`,
        );
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
        console.log(
          `Subscription changed for user: ${app_user_id}, new tier: ${tier}`,
        );
        break;

      case "TRANSFER":
        // 用户转移，更新关联
        const newUserId = event.app_user_id;
        const oldUserId = event.original_app_user_id;
        if (oldUserId && newUserId !== oldUserId) {
          await transferSubscription(supabase, oldUserId, newUserId);
          console.log(
            `Subscription transferred from ${oldUserId} to ${newUserId}`,
          );
        }
        break;

      case "REFUND":
        // 用户申请退款成功，立即撤销订阅权益
        await updateSubscriptionToFree(supabase, app_user_id);
        console.log(`Subscription refunded for user: ${app_user_id}`);
        break;

      case "SUBSCRIBER_ALIAS":
        // 用户别名关联（匿名用户登录后关联）
        // RevenueCat 会自动合并购买记录，这里只需记录日志
        console.log(
          `Subscriber alias event for user: ${app_user_id}, aliases: ${event.aliases?.join(", ") || "none"}`,
        );
        break;

      case "SUBSCRIPTION_PAUSED":
        // Google Play 订阅暂停（用户主动暂停）
        await updateSubscriptionStatus(supabase, app_user_id, "paused");
        console.log(`Subscription paused for user: ${app_user_id}`);
        break;

      case "SUBSCRIPTION_EXTENDED":
        // 订阅延长（免费延长或客服补偿）
        await upsertSubscription(supabase, {
          userId: app_user_id,
          tier,
          status: "active",
          productId: product_id,
          platform,
          expiresAt,
          originalTransactionId: original_transaction_id,
        });
        console.log(
          `Subscription extended for user: ${app_user_id}, new expiration: ${expiresAt}`,
        );
        break;

      default:
        console.log(`Unhandled event type: ${type}`);
    }

    // 记录成功的 webhook 日志
    await logWebhookEvent(supabase, event, true);

    return { success: true };
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : String(error);
    console.error("Webhook processing error:", error);

    // 记录失败的 webhook 日志
    await logWebhookEvent(supabase, event, false, errorMessage);

    return { success: false, error: errorMessage };
  }
}

// ============================================
// Subscription Status API
// ============================================

/**
 * 从 tier 计算活跃的 entitlements
 * 这与 RevenueCat Dashboard 中配置的 entitlement 映射对应
 */
function getActiveEntitlements(
  tier: SubscriptionTier,
  status: SubscriptionStatus,
): EntitlementId[] {
  // 只有活跃状态才有 entitlements
  if (status !== "active" && status !== "grace_period") {
    return [];
  }

  // tier 到 entitlements 的映射
  // Pro 用户同时拥有 plus 和 pro 权益
  switch (tier) {
    case "pro":
      return ["plus", "pro"];
    case "plus":
      return ["plus"];
    default:
      return [];
  }
}

/**
 * 获取用户订阅状态
 *
 * 返回的数据结构类似于 RevenueCat 的 CustomerInfo
 * 前端可以直接检查 active_entitlements 或 is_premium
 */
export async function getUserSubscription(
  supabase: SupabaseClient<any, string, any>,
  userId: string,
): Promise<UserSubscription> {
  const { data, error } = await supabase
    .from("user_subscriptions")
    .select("tier, status, expires_at, product_id")
    .eq("user_id", userId)
    .single();

  // PGRST116 = no rows found，表示用户没有订阅记录
  if (error && error.code !== "PGRST116") {
    console.error("Failed to get user subscription:", error);
    throw error;
  }

  const tier: SubscriptionTier = data?.tier || "free";
  const status: SubscriptionStatus = data?.status || "active";
  const activeEntitlements = getActiveEntitlements(tier, status);

  return {
    tier,
    status,
    expires_at: data?.expires_at || null,
    product_id: data?.product_id || null,
    active_entitlements: activeEntitlements,
    is_premium: activeEntitlements.length > 0,
  };
}

// ============================================
// Cleanup Functions (for Cron)
// ============================================

/**
 * 清理过期订阅 - 用于定时任务
 *
 * 这是 Webhook 的保底机制，确保即使 Webhook 失败，
 * 过期的订阅也会被正确处理。
 */
export async function cleanupExpiredSubscriptions(
  supabase: SupabaseClient<any, string, any>,
): Promise<{ cleaned: number; errors: number }> {
  let cleaned = 0;
  let errors = 0;

  // 查找已过期但状态未更新的订阅
  const { data: expiredSubscriptions, error } = await supabase
    .from("user_subscriptions")
    .select("id, user_id")
    .lt("expires_at", new Date().toISOString())
    .neq("tier", "free")
    .in("status", ["active", "grace_period"]);

  if (error) {
    console.error("Failed to fetch expired subscriptions:", error);
    return { cleaned: 0, errors: 1 };
  }

  if (!expiredSubscriptions || expiredSubscriptions.length === 0) {
    console.log("No expired subscriptions to clean up");
    return { cleaned: 0, errors: 0 };
  }

  console.log(`Found ${expiredSubscriptions.length} expired subscriptions`);

  // 批量更新为 free
  for (const sub of expiredSubscriptions) {
    const { error: updateError } = await supabase
      .from("user_subscriptions")
      .update({
        tier: "free",
        status: "expired",
      })
      .eq("id", sub.id);

    if (updateError) {
      console.error(`Failed to update subscription ${sub.id}:`, updateError);
      errors++;
    } else {
      console.log(`Cleaned up subscription for user ${sub.user_id}`);
      cleaned++;
    }
  }

  return { cleaned, errors };
}
