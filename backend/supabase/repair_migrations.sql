-- ==============================================================================
-- 手动标记 Migration 为已执行脚本
-- 当 Supabase CLI 均无法连接数据库时，在 Supabase Dashboard -> SQL Editor 中运行此脚本
-- ==============================================================================

-- 确保 schema_migrations 表存在
create schema if not exists supabase_migrations;
create table if not exists supabase_migrations.schema_migrations (
    version text not null primary key,
    statements text[],
    name text
);

-- 插入已执行的版本号（对应 backend/supabase/migrations/ 下的文件）
insert into supabase_migrations.schema_migrations (version, name, statements)
values 
    ('20260101000001', 'initial_profiles', null),
    ('20260101000002', 'core_data_schema', null),
    ('20260101000003', 'add_bookmarks', null),
    ('20260101000004', 'add_scene_order', null),
    ('20260101000005', 'data_migration_v1', null),
    ('20260101000006', 'fix_triggers', null),
    ('20260101000007', 'ensure_updated_at', null)
on conflict (version) do nothing;

-- 验证结果
select * from supabase_migrations.schema_migrations order by version;
