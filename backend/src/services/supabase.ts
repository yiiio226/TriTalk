/**
 * Supabase client utilities
 */

import { createClient, SupabaseClient } from "@supabase/supabase-js";
import type { Env } from "../types";

/**
 * Create a Supabase client with user's token for RLS.
 */
export function createSupabaseClient(env: Env, token: string) {
  return createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY, {
    global: {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    },
    db: {
      schema: env.SUPABASE_SCHEMA || "public",
    },
  });
}

/**
 * Extract token from Authorization header.
 */
export function extractToken(authHeader: string | undefined): string | null {
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return null;
  }
  return authHeader.split(" ")[1];
}
