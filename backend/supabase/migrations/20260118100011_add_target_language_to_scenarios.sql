-- Add target_language column to custom_scenarios table
-- This column stores the learning language chosen when the scene was created
-- Default value is 'English' for backward compatibility with existing scenes

ALTER TABLE custom_scenarios
ADD COLUMN IF NOT EXISTS target_language TEXT DEFAULT 'English';

-- Add a comment for documentation
COMMENT ON COLUMN custom_scenarios.target_language IS 'The target learning language when this scene was created';
