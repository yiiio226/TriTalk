-- Migration to fix schema discrepancies and add missing columns

-- 1. Vocabulary: Add missing columns
alter table vocabulary add column if not exists tag text;
alter table vocabulary add column if not exists updated_at timestamp with time zone default now();

-- 2. Custom Scenarios: Add missing columns
alter table custom_scenarios add column if not exists initial_message text;
alter table custom_scenarios add column if not exists emoji text;
alter table custom_scenarios add column if not exists category text;
alter table custom_scenarios add column if not exists goal text;
alter table custom_scenarios add column if not exists color bigint;
alter table custom_scenarios alter column color type bigint using color::bigint;
alter table custom_scenarios add column if not exists icon_path text;

-- 3. Triggers for updated_at on vocabulary
drop trigger if exists update_vocabulary_updated_at on vocabulary;
create trigger update_vocabulary_updated_at
  before update on vocabulary
  for each row
  execute function update_updated_at_column();

-- 4. User Hidden Scenes: Track deleted standard scenes
create table if not exists user_hidden_scenes (
  user_id uuid references auth.users on delete cascade not null,
  scene_id text not null,
  created_at timestamp with time zone default now(),
  primary key (user_id, scene_id)
);

alter table user_hidden_scenes enable row level security;

-- Drop existing policies to avoid "already exists" errors
drop policy if exists "Users can view own hidden scenes" on user_hidden_scenes;
drop policy if exists "Users can insert own hidden scenes" on user_hidden_scenes;
drop policy if exists "Users can delete own hidden scenes" on user_hidden_scenes;

create policy "Users can view own hidden scenes"
  on user_hidden_scenes for select
  using (auth.uid() = user_id);

create policy "Users can insert own hidden scenes"
  on user_hidden_scenes for insert
  with check (auth.uid() = user_id);

create policy "Users can delete own hidden scenes"
  on user_hidden_scenes for delete
  using (auth.uid() = user_id);
