-- Ensure chat_history has updated_at trigger

-- 1. Create or replace the trigger function (if not exists)
create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- 2. Drop existing trigger if any (to avoid conflicts)
drop trigger if exists update_chat_history_updated_at on chat_history;

-- 3. Create the trigger
create trigger update_chat_history_updated_at
  before update on chat_history
  for each row
  execute function update_updated_at_column();
