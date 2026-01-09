-- ============================================
-- Check and Fix chat_history updated_at Column
-- Ensures everything is set up correctly
-- ============================================

-- Add updated_at column if it doesn't exist (safe - won't error if exists)
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

-- Ensure the trigger function exists
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop and recreate the trigger (ensures it's properly configured)
DROP TRIGGER IF EXISTS update_chat_history_updated_at ON chat_history;

CREATE TRIGGER update_chat_history_updated_at
  BEFORE UPDATE ON chat_history
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
