-- ============================================
-- Create tritalk_schema for Dev environment isolation
-- ============================================
-- This schema is used to isolate Dev environment in a shared Supabase database
-- Prod environment will use the default 'public' schema

-- Create the schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS tritalk_schema;

-- Grant usage to all Supabase roles
GRANT USAGE ON SCHEMA tritalk_schema TO postgres, anon, authenticated, service_role;

-- Set default privileges for future objects created in tritalk_schema
ALTER DEFAULT PRIVILEGES IN SCHEMA tritalk_schema
  GRANT ALL ON TABLES TO postgres, anon, authenticated, service_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA tritalk_schema
  GRANT ALL ON SEQUENCES TO postgres, anon, authenticated, service_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA tritalk_schema
  GRANT ALL ON FUNCTIONS TO postgres, anon, authenticated, service_role;

-- Note: This migration will only be meaningful when PGOPTIONS is set to use tritalk_schema
-- For Prod deployments (using public schema), this migration creates an unused schema (harmless)
