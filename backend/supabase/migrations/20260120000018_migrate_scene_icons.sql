-- Migration: Migrate scene icons to R2 (relative paths)
-- Created based on docs/icon_migration_plan.md

-- 1. Update Standard Scenes
-- Replace 'assets/images/scenes/' locally packaged path with 'scenes/' relative path for cloud storage
UPDATE standard_scenes
SET icon_path = REGEXP_REPLACE(icon_path, '^assets/images/', '')
WHERE icon_path LIKE 'assets/images/%';

-- 2. Update Custom Scenarios (Cloned Standard Scenes)
-- Propagate the path change to user's cloned scenes that are linked to standard scenes
UPDATE custom_scenarios
SET icon_path = REGEXP_REPLACE(icon_path, '^assets/images/', '')
WHERE icon_path LIKE 'assets/images/%' 
  AND source_type = 'standard'; 
