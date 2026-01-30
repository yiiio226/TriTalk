-- Migration: 20260130000022_fix_user_fcm_tokens_rls
-- Description: Add SELECT policy for user_fcm_tokens to enable upsert operations
-- Issue: upsert requires SELECT permission to check if record exists

-- RLS Policy: Users can select their own tokens
-- This is required for upsert operations (check if token exists before insert/update)
CREATE POLICY "Users can select own tokens"
  ON user_fcm_tokens FOR SELECT
  USING (auth.uid() = user_id);
