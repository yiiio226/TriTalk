-- Add segments column to shadowing_practices table
-- This stores smart segments based on natural pauses for targeted practice
-- Nullable for backward compatibility with existing records

ALTER TABLE shadowing_practices
ADD COLUMN segments JSONB DEFAULT NULL;

-- Add comment for documentation
COMMENT ON COLUMN shadowing_practices.segments IS 'Smart segments based on natural pauses from Azure Speech API. Array of {text, start_index, end_index, score, has_error, word_count}. NULL for historical data before this feature.';
