/**
 * Supabase Admin Client
 *
 * Uses service_role key to bypass RLS for admin operations.
 * ⚠️ MUST only be used in secure server-side contexts.
 */

import { createClient, SupabaseClient } from "@supabase/supabase-js";
import type { Env } from "../types";

/**
 * Create a Supabase admin client that bypasses RLS.
 * Use this for admin operations on protected tables like `standard_scenes`.
 */
export function createSupabaseAdminClient(env: Env): SupabaseClient {
  if (!env.SUPABASE_SERVICE_ROLE_KEY) {
    throw new Error("SUPABASE_SERVICE_ROLE_KEY is not configured");
  }

  return createClient(env.SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });
}
