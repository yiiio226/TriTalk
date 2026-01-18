-- Create shadowing_practices table
CREATE TABLE shadowing_practices (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Practice context
  target_text TEXT NOT NULL,
  source_type VARCHAR(50) NOT NULL, -- 'ai_message', 'native_expression', 'reference_answer', 'custom'
  source_id VARCHAR(255), -- message_id or other reference
  scene_key VARCHAR(255), -- optional scene context
  
  -- Practice results
  pronunciation_score INTEGER NOT NULL,
  accuracy_score DECIMAL(5,2),
  fluency_score DECIMAL(5,2),
  completeness_score DECIMAL(5,2),
  prosody_score DECIMAL(5,2),
  
  -- Detailed feedback (JSONB)
  word_feedback JSONB, -- Array of word-level feedback
  feedback_text TEXT, -- Generated feedback message
  
  -- Audio reference (local only)
  audio_path TEXT, -- Local file path, not uploaded
  
  -- Metadata
  practiced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_user_practices_date ON shadowing_practices (user_id, practiced_at DESC);
CREATE INDEX idx_source_practices ON shadowing_practices (user_id, source_id, practiced_at DESC);
CREATE INDEX idx_text_practices ON shadowing_practices (user_id, target_text, practiced_at DESC);

-- Row Level Security
ALTER TABLE shadowing_practices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own practices"
  ON shadowing_practices FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own practices"
  ON shadowing_practices FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own practices
CREATE POLICY "Users can delete own practices"
  ON shadowing_practices FOR DELETE
  USING (auth.uid() = user_id);
