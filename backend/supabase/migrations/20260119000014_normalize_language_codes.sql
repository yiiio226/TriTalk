-- Migrate language fields from Display Names (English) to ISO Codes (en-US)

-- 1. Migrate `profiles` table
-- Update target_lang
UPDATE profiles 
SET target_lang = 'en-US' 
WHERE target_lang = 'English' OR target_lang IS NULL;

UPDATE profiles 
SET target_lang = 'zh-CN' 
WHERE target_lang = 'Chinese (Simplified)';

-- Update native_lang
UPDATE profiles 
SET native_lang = 'zh-CN' 
WHERE native_lang = 'Chinese (Simplified)' OR native_lang IS NULL;

UPDATE profiles 
SET native_lang = 'en-US' 
WHERE native_lang = 'English';

-- 2. Migrate `custom_scenarios` table
-- Update target_language
UPDATE custom_scenarios 
SET target_language = 'en-US' 
WHERE target_language = 'English' OR target_language IS NULL;

UPDATE custom_scenarios 
SET target_language = 'zh-CN' 
WHERE target_language = 'Chinese (Simplified)';

-- 3. Update defaults for future rows (Optional, but good practice if columns have defaults)
ALTER TABLE custom_scenarios 
ALTER COLUMN target_language SET DEFAULT 'en-US';
