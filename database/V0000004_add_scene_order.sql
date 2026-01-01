-- Migration to add user_scene_order table for cross-device scene ordering

-- Create user_scene_order table to store scene ordering preferences
create table if not exists user_scene_order (
  user_id uuid references auth.users on delete cascade not null,
  scene_order jsonb not null, -- JSON map of scene_id -> position
  updated_at timestamp with time zone default now(),
  primary key (user_id)
);

-- Enable RLS
alter table user_scene_order enable row level security;

-- Drop existing policies to avoid "already exists" errors
drop policy if exists "Users can view own scene order" on user_scene_order;
drop policy if exists "Users can insert own scene order" on user_scene_order;
drop policy if exists "Users can update own scene order" on user_scene_order;

-- Create RLS policies
create policy "Users can view own scene order"
  on user_scene_order for select
  using (auth.uid() = user_id);

create policy "Users can insert own scene order"
  on user_scene_order for insert
  with check (auth.uid() = user_id);

create policy "Users can update own scene order"
  on user_scene_order for update
  using (auth.uid() = user_id);

-- Create trigger for updated_at
drop trigger if exists update_user_scene_order_updated_at on user_scene_order;
create trigger update_user_scene_order_updated_at
  before update on user_scene_order
  for each row
  execute function update_updated_at_column();
