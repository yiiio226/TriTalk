/**
 * Admin Authentication Middleware
 *
 * Validates X-Admin-Key header for admin-only endpoints.
 */

import type { Context } from "hono";
import type { Env } from "../types";

/**
 * Middleware to verify admin API key.
 * Expects X-Admin-Key header to match ADMIN_API_KEY env variable.
 */
export const adminMiddleware = async (
  c: Context<{ Bindings: Env }>,
  next: () => Promise<void>,
) => {
  const adminKey = c.req.header("X-Admin-Key");
  const env = c.env;

  // Check if ADMIN_API_KEY is configured
  if (!env.ADMIN_API_KEY) {
    console.error("ADMIN_API_KEY is not configured");
    return c.json({ error: "Admin API is not configured" }, 500);
  }

  // Validate the provided key
  if (!adminKey || adminKey !== env.ADMIN_API_KEY) {
    return c.json({ error: "Forbidden: Invalid or missing admin key" }, 403);
  }

  await next();
};
