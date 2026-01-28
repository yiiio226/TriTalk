-- ============================================
-- Feature Quota Update Migration (2026-01-28)
-- ============================================
-- 
-- This migration updates feature quotas based on the latest pricing strategy.
-- Reference: pricing_strategy.md and feature_quota_system_design.md Section 7
--
-- Changes:
-- 1. Plus tier: Unlimited for conversation/voice/grammar, 100 TTS, 30 scenarios
-- 2. Pro tier: Unlimited for all features
-- 3. New feature: pitch_analysis (音高对比分析)
-- ============================================

-- ============================================
-- 1. Update Plus Tier Quotas
-- ============================================

-- Set unlimited (-1) for conversation, voice input, grammar analysis
UPDATE feature_limits 
SET quota_limit = -1, effective_from = NOW()
WHERE tier = 'plus' 
  AND feature_key IN ('daily_conversation', 'voice_input', 'grammar_analysis')
  AND is_active = true;

-- TTS: 100/day
UPDATE feature_limits 
SET quota_limit = 100, effective_from = NOW()
WHERE tier = 'plus' 
  AND feature_key = 'tts_speak'
  AND is_active = true;

-- Custom scenarios: 30 (static/lifetime)
UPDATE feature_limits 
SET quota_limit = 30, effective_from = NOW()
WHERE tier = 'plus' 
  AND feature_key = 'custom_scenarios'
  AND is_active = true;

-- ============================================
-- 2. Update Pro Tier Quotas
-- ============================================

-- Set unlimited (-1) for all major features
UPDATE feature_limits 
SET quota_limit = -1, effective_from = NOW()
WHERE tier = 'pro' 
  AND feature_key IN (
    'daily_conversation', 
    'voice_input', 
    'grammar_analysis', 
    'tts_speak', 
    'custom_scenarios'
  )
  AND is_active = true;

-- ============================================
-- 3. Add New Feature: Pitch Analysis (音高对比分析)
-- ============================================

-- Insert pitch_analysis for all tiers with ON CONFLICT handling
INSERT INTO feature_limits (tier, feature_key, quota_limit, refresh_period, is_active, effective_from)
VALUES
  ('free', 'pitch_analysis', 0, 'daily', true, NOW()),
  ('plus', 'pitch_analysis', -1, 'daily', true, NOW()),
  ('pro', 'pitch_analysis', -1, 'daily', true, NOW())
ON CONFLICT (tier, feature_key, effective_from) DO UPDATE
SET quota_limit = EXCLUDED.quota_limit,
    is_active = true;

-- ============================================
-- Verification Query (comment out in production)
-- ============================================
-- SELECT tier, feature_key, quota_limit, refresh_period 
-- FROM feature_limits 
-- WHERE is_active = true 
-- ORDER BY tier, feature_key;
