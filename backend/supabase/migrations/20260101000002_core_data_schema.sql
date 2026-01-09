-- ============================================
-- TriTalk Data Sync Schema
-- Tables for chat history, vocabulary, and custom scenarios
-- ============================================

-- 1. Chat History Table
-- Stores conversation history for each scenario
create table if not exists chat_history (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users on delete cascade not null,
  scene_key text not null,
  messages jsonb not null default '[]'::jsonb,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now(),
  
  -- Ensure one history per user per scene
  unique(user_id, scene_key)
);

-- Index for faster queries
create index if not exists idx_chat_history_user_id on chat_history(user_id);
create index if not exists idx_chat_history_scene_key on chat_history(user_id, scene_key);

-- RLS Policies for chat_history
alter table chat_history enable row level security;

create policy "Users can view own chat history"
  on chat_history for select
  using (auth.uid() = user_id);

create policy "Users can insert own chat history"
  on chat_history for insert
  with check (auth.uid() = user_id);

create policy "Users can update own chat history"
  on chat_history for update
  using (auth.uid() = user_id);

create policy "Users can delete own chat history"
  on chat_history for delete
  using (auth.uid() = user_id);

-- ============================================

-- 2. Vocabulary Table
-- Stores user's saved vocabulary words
create table if not exists vocabulary (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users on delete cascade not null,
  word text not null,
  translation text,
  context text,
  scene_title text,
  created_at timestamp with time zone default now()
);

-- Index for faster queries
create index if not exists idx_vocabulary_user_id on vocabulary(user_id);
create index if not exists idx_vocabulary_created_at on vocabulary(user_id, created_at desc);

-- RLS Policies for vocabulary
alter table vocabulary enable row level security;

create policy "Users can view own vocabulary"
  on vocabulary for select
  using (auth.uid() = user_id);

create policy "Users can insert own vocabulary"
  on vocabulary for insert
  with check (auth.uid() = user_id);

create policy "Users can update own vocabulary"
  on vocabulary for update
  using (auth.uid() = user_id);

create policy "Users can delete own vocabulary"
  on vocabulary for delete
  using (auth.uid() = user_id);

-- ============================================

-- 3. Custom Scenarios Table
-- Stores user-created custom scenarios
create table if not exists custom_scenarios (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users on delete cascade not null,
  title text not null,
  description text,
  ai_role text not null,
  user_role text not null,
  difficulty text default 'intermediate',
  image_url text,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Index for faster queries
create index if not exists idx_custom_scenarios_user_id on custom_scenarios(user_id);
create index if not exists idx_custom_scenarios_created_at on custom_scenarios(user_id, created_at desc);

-- RLS Policies for custom_scenarios
alter table custom_scenarios enable row level security;

create policy "Users can view own scenarios"
  on custom_scenarios for select
  using (auth.uid() = user_id);

create policy "Users can insert own scenarios"
  on custom_scenarios for insert
  with check (auth.uid() = user_id);

create policy "Users can update own scenarios"
  on custom_scenarios for update
  using (auth.uid() = user_id);

create policy "Users can delete own scenarios"
  on custom_scenarios for delete
  using (auth.uid() = user_id);

-- ============================================

-- Trigger to update updated_at timestamp
create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Apply trigger to tables
create trigger update_chat_history_updated_at
  before update on chat_history
  for each row
  execute function update_updated_at_column();

create trigger update_custom_scenarios_updated_at
  before update on custom_scenarios
  for each row
  execute function update_updated_at_column();
