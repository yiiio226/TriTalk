-- Migration: Migrate icon_path from local assets to R2 relative paths
-- This migration updates icon_path to use relative paths that will be
-- prefixed with the R2 base URL at runtime.
-- 
-- Before: 'assets/images/scenes/xxx.png'
-- After:  'scenes/xxx.png'

-- ============================================
-- 1. Update standard_scenes (Seed Library)
-- ============================================
-- Transform local asset paths to R2 relative paths

UPDATE standard_scenes
SET icon_path = REGEXP_REPLACE(icon_path, '^assets/images/', '')
WHERE icon_path LIKE 'assets/images/%';

-- ============================================
-- 2. Update custom_scenarios (User's Cloned Scenes)
-- ============================================
-- Only update scenes that were cloned from standard_scenes
-- to prevent affecting user-uploaded custom icons (if any in future)

UPDATE custom_scenarios
SET icon_path = REGEXP_REPLACE(icon_path, '^assets/images/', '')
WHERE icon_path LIKE 'assets/images/%'
  AND source_type = 'standard';

-- ============================================
-- 3. Update handle_new_user_scenes() function
-- ============================================
-- Recreate the trigger function to ensure new user scene clones
-- use the updated icon_path values from standard_scenes.
-- (This is already handled automatically since the function copies
-- from standard_scenes.icon_path which we just updated)

-- No function update needed - it already references standard_scenes.icon_path dynamically.

-- ============================================
-- Verification Queries (for manual check)
-- ============================================
-- Run these after migration to verify:
-- SELECT icon_path FROM standard_scenes LIMIT 5;
-- SELECT icon_path FROM custom_scenarios WHERE source_type = 'standard' LIMIT 5;
-- Expected: 'scenes/xxx.png' format
