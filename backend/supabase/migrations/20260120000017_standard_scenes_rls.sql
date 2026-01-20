-- Migration: Enable RLS for standard_scenes table
-- Purpose: Allow public read access, restrict write to service_role only
-- Reference: Design decision discussed on 2026-01-20

-- ============================================
-- 1. ENABLE ROW LEVEL SECURITY
-- ============================================

ALTER TABLE standard_scenes ENABLE ROW LEVEL SECURITY;


-- ============================================
-- 2. READ POLICY: Allow all users to read
-- ============================================

-- Both authenticated and anonymous users can read standard scenes
-- This is needed for:
--   1. The handle_new_user_scenes trigger to copy scenes to new users
--   2. Future "Restore Default" feature that may need to read from this table
CREATE POLICY "Anyone can read standard_scenes"
  ON standard_scenes FOR SELECT
  USING (true);


-- ============================================
-- 3. NO WRITE POLICIES (By Design)
-- ============================================

-- We intentionally DO NOT create INSERT/UPDATE/DELETE policies.
-- This means:
--   - anon/authenticated users CANNOT write to this table
--   - service_role key CAN write (bypasses RLS)
--   - Migration scripts CAN write (run as superuser)
--   - Supabase Dashboard CAN write (uses service_role)

-- To add new standard scenes:
--   Option A: Create a new migration file with INSERT statements (recommended)
--   Option B: Use Supabase Dashboard Table Editor
--   Option C: Backend script using SUPABASE_SERVICE_ROLE_KEY

