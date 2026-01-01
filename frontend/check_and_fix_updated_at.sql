-- ============================================
-- Check and Fix chat_history updated_at Column
-- Run this in Supabase SQL Editor to ensure everything is set up correctly
-- ============================================

-- Step 1: Check if updated_at column exists
-- If this query returns a row, the column exists
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'chat_history' 
  AND column_name = 'updated_at';

-- Step 2: Add updated_at column if it doesn't exist (safe - won't error if exists)
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'chat_history' AND column_name = 'updated_at'
  ) THEN
    ALTER TABLE chat_history 
    ADD COLUMN updated_at timestamp with time zone DEFAULT now();
    
    RAISE NOTICE 'Added updated_at column to chat_history table';
  ELSE
    RAISE NOTICE 'updated_at column already exists in chat_history table';
  END IF;
END $$;

-- Step 3: Ensure the trigger function exists
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 4: Drop and recreate the trigger (ensures it's properly configured)
DROP TRIGGER IF EXISTS update_chat_history_updated_at ON chat_history;

CREATE TRIGGER update_chat_history_updated_at
  BEFORE UPDATE ON chat_history
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Step 5: Verify the trigger is active
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE event_object_table = 'chat_history'
  AND trigger_name = 'update_chat_history_updated_at';

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Check current chat_history structure
SELECT 
  column_name,
  data_type,
  column_default,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'chat_history'
ORDER BY ordinal_position;

-- Test: Update a record to verify trigger works
-- (Uncomment and modify with a real user_id and scene_key to test)
/*
UPDATE chat_history 
SET messages = messages 
WHERE user_id = 'your-user-id-here' 
  AND scene_key = 'test-scene'
RETURNING id, updated_at;
*/

-- ============================================
-- SUCCESS MESSAGE
-- ============================================
DO $$ 
BEGIN
  RAISE NOTICE '✅ chat_history table is now configured with updated_at column and trigger!';
  RAISE NOTICE 'The trigger will automatically update updated_at whenever a row is modified.';
END $$;
