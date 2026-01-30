-- Migration: Migrate scene generation trigger from auth.users to profiles
-- Purpose: 
--   1. Remove old trigger (on_auth_user_created_scenes) that fired on user creation
--   2. Create new trigger (on_profile_language_updated) that fires when target_lang is set/updated
-- This enables scenes to be generated when user completes Onboarding, not at registration time.
-- The new trigger also supports localized content based on user's native language.

-- ============================================
-- Step 1: Remove old trigger and function
-- ============================================
DROP TRIGGER IF EXISTS on_auth_user_created_scenes ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user_scenes();

-- ============================================
-- Step 2: Create new function with localization support
-- ============================================
CREATE OR REPLACE FUNCTION handle_user_scene_generation()
RETURNS TRIGGER AS $$
BEGIN
  -- Guard 1: target_lang must be set
  -- This ensures we only generate scenes when user has selected a target language
  IF NEW.target_lang IS NULL THEN
    RETURN NEW;
  END IF;

  -- Guard 2: On UPDATE, only proceed if target_lang actually changed
  -- This prevents duplicate scene generation on unrelated profile updates
  IF TG_OP = 'UPDATE' AND OLD.target_lang IS NOT DISTINCT FROM NEW.target_lang THEN
    RETURN NEW;
  END IF;

  -- Guard 3: If user already has scenes, skip (only generate during Onboarding)
  -- This ensures Profile page language changes do NOT regenerate scenes
  IF EXISTS (SELECT 1 FROM custom_scenarios WHERE user_id = NEW.id LIMIT 1) THEN
    RETURN NEW;
  END IF;

  -- Insert scenes with localization fallback and deduplication
  INSERT INTO custom_scenarios (
    user_id,
    title,
    description,
    ai_role,
    user_role,
    initial_message,
    goal,
    emoji,
    category,
    difficulty,
    icon_path,
    color,
    target_language,
    origin_standard_id,
    source_type,
    updated_at
  )
  SELECT
    NEW.id,
    -- Title localization: prefer native language -> English fallback -> original
    COALESCE(
      s.translations -> NEW.native_lang ->> 'title',
      s.translations -> 'en-US' ->> 'title',
      s.title
    ),
    -- Description localization
    COALESCE(
      s.translations -> NEW.native_lang ->> 'description',
      s.translations -> 'en-US' ->> 'description',
      s.description
    ),
    s.ai_role,
    s.user_role,
    s.initial_message,
    -- Goal localization
    COALESCE(
      s.translations -> NEW.native_lang ->> 'goal',
      s.translations -> 'en-US' ->> 'goal',
      s.goal
    ),
    s.emoji,
    s.category,
    s.difficulty,
    s.icon_path,
    s.color,
    s.target_language,
    s.id,
    'standard',
    -- Use ROW_NUMBER offset to maintain predictable initial order
    NOW() - (ROW_NUMBER() OVER (ORDER BY s.id) * INTERVAL '1 second')
  FROM standard_scenes s
  WHERE s.target_language = NEW.target_lang
     OR (
       -- Fallback logic: if no scenes exist for target language, use English scenes
       NOT EXISTS (SELECT 1 FROM standard_scenes WHERE target_language = NEW.target_lang)
       AND s.target_language = 'en-US'
     )
  ON CONFLICT DO NOTHING;  -- Prevent duplicate insertions

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- Step 3: Create new trigger on profiles table
-- ============================================
-- This trigger fires when:
--   - A new profile is inserted (e.g., via handle_new_user)
--   - The target_lang column is updated (e.g., user changes learning language)
DROP TRIGGER IF EXISTS on_profile_language_updated ON profiles;
CREATE TRIGGER on_profile_language_updated
  AFTER INSERT OR UPDATE OF target_lang ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION handle_user_scene_generation();

-- ============================================
-- Note: No migration needed for existing users
-- ============================================
-- Existing users already have scenes from the old trigger.
-- New users will get scenes when they complete Onboarding and set target_lang.
-- If an existing user updates their target_lang, new scenes will be generated.
