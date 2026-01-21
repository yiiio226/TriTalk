create table if not exists dummy (
  id uuid primary key, -- client-generated UUID  
  created_at timestamp with time zone default now(),
);