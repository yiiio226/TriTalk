/**
 * Authentication service
 */

import type { Context } from "hono";
import type { Env } from "../types";
import { createSupabaseClient, extractToken } from "./supabase";

/**
 * Authenticate user via Supabase.
 * Returns the user object if authenticated, null otherwise.
 */
export async function authenticateUser(c: Context): Promise<any> {
  const authHeader = c.req.header("Authorization");
  const token = extractToken(authHeader);

  if (!token) {
    return null;
  }

  const env = c.env as Env;

  try {
    const supabase = createSupabaseClient(env, token);

    const {
      data: { user },
      error,
    } = await supabase.auth.getUser();

    if (error || !user) {
      console.error("Auth Error:", error);
      return null;
    }

    // Optional: Check profile
    const { data: profile, error: profileError } = await supabase
      .from("profiles")
      .select("*")
      .eq("id", user.id)
      .single();

    if (profileError || !profile) {
      console.error("Profile Error:", profileError);
      // Allow if Auth is valid even if profile fetch fails
    }

    return user;
  } catch (e) {
    console.error("Auth Exception:", e);
    return null;
  }
}

/**
 * Authentication middleware for Hono.
 */
export const authMiddleware = async (c: Context, next: any) => {
  const user = await authenticateUser(c);
  if (!user) {
    return c.json(
      {
        error: "Unauthorized: Invalid User Token or Subscription",
      },
      401
    );
  }
  c.set("user", user);
  await next();
};
