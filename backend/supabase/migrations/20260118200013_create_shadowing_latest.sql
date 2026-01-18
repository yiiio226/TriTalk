-- Migration: Drop old shadowing_practices and create new shadowing_latest
-- Purpose: Each source (user + source_type + source_id) only keeps the latest practice record

-- Drop old table (no backward compatibility needed per design doc)
DROP TABLE IF EXISTS shadowing_practices;

-- Create new table with unique constraint for upsert pattern
CREATE TABLE shadowing_latest (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Unique key combination
  source_type VARCHAR(50) NOT NULL,  -- 'ai_message', 'native_expression', 'reference_answer'
  source_id VARCHAR(255) NOT NULL,   -- message_id

  -- Actual content (for display, not part of uniqueness)
  target_text TEXT NOT NULL,
  scene_key VARCHAR(255),            -- scene key (record only, not part of uniqueness)

  -- Latest practice results
  pronunciation_score INTEGER NOT NULL,
  accuracy_score DECIMAL(5,2),
  fluency_score DECIMAL(5,2),
  completeness_score DECIMAL(5,2),
  prosody_score DECIMAL(5,2),

  -- Detailed feedback
  word_feedback JSONB,
  feedback_text TEXT,
  segments JSONB,

  -- Timestamps
  practiced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Unique constraint: each user + source_type + source_id has only one record
  UNIQUE(user_id, source_type, source_id)
);

-- Index for fast lookup by unique key
CREATE INDEX idx_shadowing_lookup
  ON shadowing_latest (user_id, source_type, source_id);

-- Row Level Security
ALTER TABLE shadowing_latest ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own practices"
  ON shadowing_latest FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own practices"
  ON shadowing_latest FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own practices"
  ON shadowing_latest FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own practices"
  ON shadowing_latest FOR DELETE
  USING (auth.uid() = user_id);
