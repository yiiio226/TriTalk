-- Migration: 20260130000021_create_user_fcm_tokens
-- Description: Create user_fcm_tokens table for multi-device push notification support
-- Design: fcm_token as primary key to support multiple devices per user

-- Create the user_fcm_tokens table
-- Each record represents one App installation instance (device)
CREATE TABLE IF NOT EXISTS user_fcm_tokens (
  -- FCM Token uniquely identifies a device, used as primary key
  fcm_token TEXT PRIMARY KEY,

  -- User who owns this token
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Platform identifier: 'android', 'iOS'  
  platform TEXT NOT NULL,

  -- Used for periodic cleanup of long-inactive tokens
  last_active_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Record creation timestamp
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add comment to table
COMMENT ON TABLE user_fcm_tokens IS 'Stores FCM tokens for push notifications. Supports multiple devices per user.';
COMMENT ON COLUMN user_fcm_tokens.fcm_token IS 'FCM device token, unique per app installation';
COMMENT ON COLUMN user_fcm_tokens.user_id IS 'User who owns this device token';
COMMENT ON COLUMN user_fcm_tokens.platform IS 'Device platform: android or iOS';
COMMENT ON COLUMN user_fcm_tokens.last_active_at IS 'Last time this token was used/updated, for cleanup purposes';

-- Index: Fast lookup for all devices belonging to a user
CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_user_id ON user_fcm_tokens(user_id);

-- Index: Efficient cleanup of stale tokens
CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_last_active ON user_fcm_tokens(last_active_at);

-- Enable Row Level Security
ALTER TABLE user_fcm_tokens ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only insert their own tokens
CREATE POLICY "Users can insert own tokens"
  ON user_fcm_tokens FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can only update their own tokens
CREATE POLICY "Users can update own tokens"
  ON user_fcm_tokens FOR UPDATE
  USING (auth.uid() = user_id);

-- RLS Policy: Users can only delete their own tokens
CREATE POLICY "Users can delete own tokens"
  ON user_fcm_tokens FOR DELETE
  USING (auth.uid() = user_id);

-- Note: No SELECT policy for regular users
-- Backend uses service_role key to SELECT tokens for push notifications
-- This is a security measure - users don't need to read their own tokens
