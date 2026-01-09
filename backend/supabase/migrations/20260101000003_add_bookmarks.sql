-- Create table for bookmarked conversations (Chat Favorites)
create table if not exists bookmarked_conversations (
  id uuid primary key, -- client-generated UUID
  user_id uuid references auth.users on delete cascade not null,
  title text not null,
  preview text not null,
  date text not null, -- Stored as string to match current app usage
  scene_key text not null,
  messages jsonb not null default '[]'::jsonb, -- Store full conversation snapshot
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Indexes
create index if not exists idx_bookmarked_conversations_user_id on bookmarked_conversations(user_id);
create index if not exists idx_bookmarked_conversations_created_at on bookmarked_conversations(user_id, created_at desc);

-- RLS Policies
alter table bookmarked_conversations enable row level security;

create policy "Users can view own bookmarks"
  on bookmarked_conversations for select
  using (auth.uid() = user_id);

create policy "Users can insert own bookmarks"
  on bookmarked_conversations for insert
  with check (auth.uid() = user_id);

create policy "Users can update own bookmarks"
  on bookmarked_conversations for update
  using (auth.uid() = user_id);

create policy "Users can delete own bookmarks"
  on bookmarked_conversations for delete
  using (auth.uid() = user_id);

-- Trigger for updated_at
create trigger update_bookmarked_conversations_updated_at
  before update on bookmarked_conversations
  for each row
  execute function update_updated_at_column();
