-- Migration: Fix scene generation logic to correctly use user's target language
-- File: 20260130000027_fix_scene_generation_language.sql

CREATE OR REPLACE FUNCTION handle_user_scene_generation()
RETURNS TRIGGER AS $$
BEGIN
  -- Guard 1: target_lang must be set
  IF NEW.target_lang IS NULL THEN
    RETURN NEW;
  END IF;

  -- Guard 2: On UPDATE, only proceed if target_lang actually changed
  IF TG_OP = 'UPDATE' AND OLD.target_lang IS NOT DISTINCT FROM NEW.target_lang THEN
    RETURN NEW;
  END IF;

  -- Guard 3: If user already has scenes, skip (only generate during Onboarding)
  -- This ensures Profile page language changes do NOT regenerate scenes
  IF EXISTS (SELECT 1 FROM custom_scenarios WHERE user_id = NEW.id LIMIT 1) THEN
    RETURN NEW;
  END IF;

  -- Insert scenes with localization fallback
  INSERT INTO custom_scenarios (
    user_id, title, description, ai_role, user_role, initial_message,
    goal, emoji, category, difficulty, icon_path, color,
    target_language, origin_standard_id, source_type, updated_at
  )
  SELECT
    NEW.id,
    -- Title localization: Use Target Language -> English -> Original
    -- User Requested: Use NEW.target_lang for translation lookup
    COALESCE(s.translations -> NEW.target_lang ->> 'title', s.translations -> 'en-US' ->> 'title', s.title),
    -- Description localization: Use Target Language
    COALESCE(s.translations -> NEW.target_lang ->> 'description', s.translations -> 'en-US' ->> 'description', s.description),
    s.ai_role, 
    s.user_role, 
    s.initial_message,
    -- Goal localization: Use Target Language
    COALESCE(s.translations -> NEW.target_lang ->> 'goal', s.translations -> 'en-US' ->> 'goal', s.goal),
    s.emoji, 
    s.category, 
    s.difficulty, 
    s.icon_path, 
    s.color,
    -- FORCE target_language to be the USER's target language (e.g., 'es-ES'), 
    -- even if we are falling back to 'en-US' scenes content.
    NEW.target_lang,
    s.id, 
    'standard',
    NOW() - (ROW_NUMBER() OVER (ORDER BY s.id) * INTERVAL '1 second')
  FROM standard_scenes s
  WHERE s.target_language = NEW.target_lang
     OR (
       -- Fallback logic: If no scenes exist for this target language, use English scenes
       NOT EXISTS (SELECT 1 FROM standard_scenes WHERE target_language = NEW.target_lang)
       AND s.target_language = 'en-US'
     )
  ON CONFLICT DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
