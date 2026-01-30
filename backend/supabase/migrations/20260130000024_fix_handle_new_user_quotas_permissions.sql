-- Fix handle_new_user_quotas permissions for Google login
-- 
-- Problem: The original function was created with standard permissions (SECURITY INVOKER)
-- and without a specific search_path. When triggered by auth (e.g. Google login), 
-- it runs as 'supabase_auth_admin' which does not have permission to access 
-- the 'tritalk_schema/public' schema, causing "permission denied" errors (500).
--
-- Solution: 
-- 1. Use SECURITY DEFINER to run the function with the creator's permissions
-- 2. Explicitly set search_path for safety
-- 3. Explicitly reference tritalk_schema in the INSERT statement
-- 4. Add ON CONFLICT DO NOTHING to prevent unique violation errors

CREATE OR REPLACE FUNCTION handle_new_user_quotas()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO user_feature_usage (user_id, usage_data)
  VALUES (NEW.id, '{}'::jsonb)
  ON CONFLICT (user_id) DO NOTHING;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Set a secure search path to prevent malicious object creation
ALTER FUNCTION handle_new_user_quotas() 
SET search_path = tritalk_schema, public;
