CREATE TABLE IF NOT EXISTS dummy (
  id uuid PRIMARY KEY,
  created_at timestamp with time zone DEFAULT now()
);