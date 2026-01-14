-- Re-add icon_path column to custom_scenarios table
-- This field is needed for custom scene icons in the Flutter app

alter table custom_scenarios add column if not exists icon_path text default '';
