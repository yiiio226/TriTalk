-- 修改 profiles 表的外键，添加级联删除
--
-- 设计说明：profiles 表不需要 DELETE RLS 策略，原因如下：
-- 1. 账号删除通过 Supabase Auth Admin API 执行，会自动触发 ON DELETE CASCADE
-- 2. 普通用户不应该有直接删除 profiles 记录的权限
-- 3. Admin 操作使用 service_role key 绕过 RLS

ALTER TABLE profiles
DROP CONSTRAINT profiles_id_fkey;

ALTER TABLE profiles
ADD CONSTRAINT profiles_id_fkey
    FOREIGN KEY (id)
    REFERENCES auth.users(id)
    ON DELETE CASCADE;
