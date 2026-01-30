/**
 * FCM Push Notification Service for Cloudflare Workers
 *
 * Uses FCM HTTP v1 API directly since firebase-admin SDK requires Node.js native APIs
 * that are not available in Cloudflare Workers runtime.
 *
 * @see https://firebase.google.com/docs/cloud-messaging/send-message
 */

import { getGCPAccessToken } from "../auth/gcp-auth";
import { createSupabaseAdminClient } from "./supabase-admin";
import type { Env } from "../types";

// ============================================================================
// Types
// ============================================================================

export interface PushNotification {
  /** Notification title displayed to user */
  title: string;
  /** Notification body text */
  body: string;
  /** Optional custom data payload (key-value pairs) */
  data?: Record<string, string>;
  /** Optional image URL to display in notification */
  imageUrl?: string;
}

export interface SendResult {
  /** Number of successfully sent notifications */
  sent: number;
  /** Number of failed/invalid tokens (cleaned up) */
  failed: number;
  /** List of cleaned up invalid tokens */
  invalidTokens?: string[];
}

interface FCMMessage {
  message: {
    token: string;
    notification: {
      title: string;
      body: string;
      image?: string;
    };
    data?: Record<string, string>;
    android?: {
      priority: "high" | "normal";
      notification?: {
        channel_id?: string;
        click_action?: string;
      };
    };
    apns?: {
      payload: {
        aps: {
          alert?: {
            title?: string;
            body?: string;
          };
          sound?: string;
          badge?: number;
        };
      };
    };
  };
}

interface FCMErrorResponse {
  error?: {
    code?: number;
    message?: string;
    status?: string;
    details?: Array<{
      "@type"?: string;
      errorCode?: string;
      description?: string;
    }>;
  };
}

// ============================================================================
// Configuration Check
// ============================================================================

/**
 * Check if Firebase FCM is configured
 */
export function isFCMConfigured(env: Env): boolean {
  return !!(
    env.FIREBASE_PROJECT_ID &&
    env.FIREBASE_CLIENT_EMAIL &&
    env.FIREBASE_PRIVATE_KEY
  );
}

// ============================================================================
// Main Push Functions
// ============================================================================

/**
 * Send push notification to all devices of a specific user
 *
 * [Multi-device Support] Queries user_fcm_tokens table for all device tokens
 * and sends notifications concurrently.
 *
 * @param env - Cloudflare Workers environment
 * @param userId - Target user's UUID
 * @param notification - Notification content
 * @returns Send result with success/failure counts
 */
export async function sendPushToUser(
  env: Env,
  userId: string,
  notification: PushNotification,
): Promise<SendResult> {
  if (!isFCMConfigured(env)) {
    console.warn("[FCM] Firebase not configured, skipping push");
    return { sent: 0, failed: 0 };
  }

  const supabase = createSupabaseAdminClient(env);

  // 1. Query all device tokens for this user
  const { data: tokens, error } = await supabase
    .from("user_fcm_tokens")
    .select("fcm_token, platform")
    .eq("user_id", userId);

  if (error) {
    console.error("[FCM] Failed to query tokens:", error);
    return { sent: 0, failed: 0 };
  }

  if (!tokens?.length) {
    console.log(`[FCM] No registered devices for user ${userId}`);
    return { sent: 0, failed: 0 };
  }

  console.log(`[FCM] Sending to ${tokens.length} device(s) for user ${userId}`);

  // 2. Get Firebase Access Token (using Firebase-specific credentials)
  const accessToken = await getGCPAccessToken(
    env.FIREBASE_CLIENT_EMAIL!,
    env.FIREBASE_PRIVATE_KEY!,
    "https://www.googleapis.com/auth/firebase.messaging",
  );

  // 3. Send to all devices concurrently
  const results = await Promise.allSettled(
    tokens.map((t) =>
      sendSinglePush(env, accessToken, t.fcm_token, notification),
    ),
  );

  // 4. Collect and cleanup invalid tokens
  const invalidTokens: string[] = [];
  results.forEach((result, idx) => {
    if (result.status === "rejected") {
      const error = result.reason;
      if (isUnregisteredError(error)) {
        invalidTokens.push(tokens[idx].fcm_token);
        console.log(
          `[FCM] Token invalidated (UNREGISTERED): ${tokens[idx].fcm_token.substring(0, 20)}...`,
        );
      } else {
        console.error(
          `[FCM] Unexpected send error:`,
          JSON.stringify(error, null, 2),
        );
      }
    }
  });

  // Batch delete invalid tokens
  if (invalidTokens.length > 0) {
    const { error: deleteError } = await supabase
      .from("user_fcm_tokens")
      .delete()
      .in("fcm_token", invalidTokens);

    if (deleteError) {
      console.error("[FCM] Failed to cleanup invalid tokens:", deleteError);
    } else {
      console.log(`[FCM] Cleaned up ${invalidTokens.length} invalid token(s)`);
    }
  }

  const sent = results.filter((r) => r.status === "fulfilled").length;
  console.log(
    `[FCM] Push complete: ${sent} sent, ${invalidTokens.length} failed`,
  );

  return {
    sent,
    failed: invalidTokens.length,
    invalidTokens: invalidTokens.length > 0 ? invalidTokens : undefined,
  };
}

/**
 * Send push notification to multiple users
 *
 * Useful for broadcast notifications or group messages.
 *
 * @param env - Cloudflare Workers environment
 * @param userIds - Array of target user UUIDs
 * @param notification - Notification content
 * @returns Aggregated send result
 */
export async function sendPushToUsers(
  env: Env,
  userIds: string[],
  notification: PushNotification,
): Promise<SendResult> {
  const results = await Promise.allSettled(
    userIds.map((userId) => sendPushToUser(env, userId, notification)),
  );

  let totalSent = 0;
  let totalFailed = 0;
  const allInvalidTokens: string[] = [];

  results.forEach((result) => {
    if (result.status === "fulfilled") {
      totalSent += result.value.sent;
      totalFailed += result.value.failed;
      if (result.value.invalidTokens) {
        allInvalidTokens.push(...result.value.invalidTokens);
      }
    }
  });

  return {
    sent: totalSent,
    failed: totalFailed,
    invalidTokens: allInvalidTokens.length > 0 ? allInvalidTokens : undefined,
  };
}

// ============================================================================
// Internal Functions
// ============================================================================

/**
 * Send a single push notification using FCM HTTP v1 API
 *
 * @see https://firebase.google.com/docs/cloud-messaging/send-message#send-messages-to-specific-devices
 */
async function sendSinglePush(
  env: Env,
  accessToken: string,
  token: string,
  notification: PushNotification,
): Promise<void> {
  const projectId = env.FIREBASE_PROJECT_ID!;
  const url = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

  const message: FCMMessage = {
    message: {
      token,
      notification: {
        title: notification.title,
        body: notification.body,
        ...(notification.imageUrl && { image: notification.imageUrl }),
      },
      ...(notification.data && { data: notification.data }),
      // Android-specific settings
      android: {
        priority: "high",
        notification: {
          channel_id: "high_importance_channel", // Match Flutter channel
        },
      },
      // iOS-specific settings
      apns: {
        payload: {
          aps: {
            sound: "default",
          },
        },
      },
    },
  };

  const response = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(message),
  });

  if (!response.ok) {
    const errorBody = await response.text();
    let error: FCMErrorResponse;
    try {
      error = JSON.parse(errorBody);
    } catch {
      throw new Error(`FCM request failed: ${response.status} - ${errorBody}`);
    }
    throw error;
  }
}

/**
 * Check if error indicates token is no longer valid (unregistered)
 *
 * FCM HTTP v1 API error format differs from Admin SDK.
 * UNREGISTERED means the app was uninstalled or token was invalidated.
 */
function isUnregisteredError(error: unknown): boolean {
  if (typeof error !== "object" || error === null) return false;

  const fcmError = error as FCMErrorResponse;

  // Check in details array (primary location)
  if (fcmError.error?.details) {
    const hasUnregistered = fcmError.error.details.some(
      (d) => d.errorCode === "UNREGISTERED",
    );
    if (hasUnregistered) return true;
  }

  // Also check error message as fallback
  if (fcmError.error?.message?.includes("UNREGISTERED")) {
    return true;
  }

  return false;
}

// ============================================================================
// Utility Functions
// ============================================================================

/**
 * Clean up stale FCM tokens that haven't been active for a specified period
 *
 * Recommended to run periodically (e.g., daily) via scheduled task.
 *
 * @param env - Cloudflare Workers environment
 * @param daysInactive - Number of days of inactivity before cleanup (default: 30)
 * @returns Number of tokens deleted
 */
export async function cleanupStaleTokens(
  env: Env,
  daysInactive: number = 30,
): Promise<number> {
  const supabase = createSupabaseAdminClient(env);

  const cutoffDate = new Date();
  cutoffDate.setDate(cutoffDate.getDate() - daysInactive);

  const { data, error } = await supabase
    .from("user_fcm_tokens")
    .delete()
    .lt("last_active_at", cutoffDate.toISOString())
    .select("fcm_token");

  if (error) {
    console.error("[FCM] Failed to cleanup stale tokens:", error);
    return 0;
  }

  const count = data?.length || 0;
  if (count > 0) {
    console.log(`[FCM] Cleaned up ${count} stale token(s)`);
  }

  return count;
}
