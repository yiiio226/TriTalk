-- Migration: Implement Pure Clone Model for Scenes
-- Created based on docs/standard_scenes_migration_plan.md

-- ============================================
-- 1. CLEANUP OLD TABLES & DATA (Dev Only)
-- ============================================

-- Clean up old mock ID references first
DELETE FROM chat_history WHERE scene_key ~ '^s[0-9]+$';
DELETE FROM bookmarked_conversations WHERE scene_key ~ '^s[0-9]+$';

-- Drop obsolete tables
DROP TABLE IF EXISTS user_hidden_scenes;
DROP TABLE IF EXISTS user_scene_order;


-- ============================================
-- 2. CREATE SEED LIBRARY (Standard Scenes)
-- ============================================

CREATE TABLE IF NOT EXISTS standard_scenes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  ai_role TEXT NOT NULL,
  user_role TEXT NOT NULL,
  initial_message TEXT NOT NULL,
  goal TEXT NOT NULL,
  emoji TEXT NOT NULL DEFAULT '🎭',
  category TEXT NOT NULL,
  difficulty TEXT NOT NULL,
  icon_path TEXT,
  color BIGINT NOT NULL,
  target_language TEXT NOT NULL DEFAULT 'en-US', -- BCP-47 compliant
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed Data (13 Standard Scenes)
-- Using 'en-US' as default language code, as requested.
INSERT INTO standard_scenes (id, title, description, emoji, ai_role, user_role, initial_message, category, difficulty, goal, icon_path, color, target_language)
VALUES
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Order Coffee', 'Order a coffee', '☕', 'Barista', 'Customer', 'Hi! What can I get for you today?', 'Daily Life', 'Easy', 'Order a coffee', 'assets/images/scenes/coffee_3d.png', 4292932337, 'en-US'),
  ('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'Check-in at Immigration', 'Answer questions and get through immigration', '✈️', 'Immigration Officer', 'Traveler', 'Good morning. May I see your passport?', 'Travel', 'Medium', 'Answer questions and get through immigration', 'assets/images/scenes/plane_3d.png', 4294965473, 'en-US'),
  ('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'Lost Wallet', 'Ask for help finding your wallet', '👛', 'Helpful Stranger', 'Person who lost wallet', 'Excuse me, you look worried. Is everything okay?', 'Emergency', 'Hard', 'Ask for help finding your wallet', 'assets/images/scenes/wallet_3d.png', 4294962158, 'en-US'),
  ('d3eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', 'Taking a Taxi', 'Give directions to the driver', '🚕', 'Taxi Driver', 'Passenger', 'Hello! Where are you heading to today?', 'Daily Life', 'Easy', 'Reach your destination', 'assets/images/scenes/taxi_3d.png', 4294964192, 'en-US'),
  ('e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a15', 'Supermarket Shopping', 'Ask where to find items', '🛒', 'Supermarket Staff', 'Customer', 'Hi there! Can I help you find anything?', 'Daily Life', 'Easy', 'Find all items on your list', 'assets/images/scenes/supermarket_3d.png', 4293457385, 'en-US'),
  ('f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a16', 'Asking for Directions', 'Ask a local for directions', '🗺️', 'Local', 'Lost Traveler', 'Hello! Do you need some help finding your way?', 'Travel', 'Medium', 'Find the way to your destination', 'assets/images/scenes/map_3d.png', 4293128957, 'en-US'),
  ('06eebc99-9c0b-4ef8-bb6d-6bb9bd380a17', 'First Meeting', 'Introduce yourself to a new friend', '🤝', 'New Friend', 'Self', 'Hi! Nice to meet you. I''m Alex.', 'Social', 'Easy', 'Get to know each other', 'assets/images/scenes/handshake_3d.png', 4293457385, 'en-US'),
  ('17eebc99-9c0b-4ef8-bb6d-6bb9bd380a18', 'Hotel Check-in', 'Check in to your hotel room', '🏨', 'Receptionist', 'Guest', 'Welcome! Do you have a reservation with us?', 'Travel', 'Medium', 'Successfully check in', 'assets/images/scenes/hotel_3d.png', 4292932337, 'en-US'),
  ('28eebc99-9c0b-4ef8-bb6d-6bb9bd380a19', 'Restaurant Ordering', 'Order food at a restaurant', '🍽️', 'Waiter', 'Customer', 'Good evening. Here is the menu. Are you ready to order?', 'Daily Life', 'Medium', 'Order your meal', 'assets/images/scenes/food_3d.png', 4294703591, 'en-US'),
  ('39eebc99-9c0b-4ef8-bb6d-6bb9bd380a20', 'Job Interview', 'Answer interview questions', '💼', 'Interviewer', 'Candidate', 'Thank you for coming in through. Tell me a bit about yourself.', 'Business', 'Hard', 'Impress the interviewer', 'assets/images/scenes/interview_3d.png', 4293717937, 'en-US'),
  ('4aeebc99-9c0b-4ef8-bb6d-6bb9bd380a21', 'Business Meeting', 'Discuss a project with colleagues', '📊', 'Colleague', 'Project Manager', 'Shall we get started with the project update?', 'Business', 'Hard', 'Coordinate the project next steps', 'assets/images/scenes/meeting_3d.png', 4293454582, 'en-US'),
  ('5beebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'Movie Discussion', 'Talk about a movie you saw', '🎬', 'Friend', 'Self', 'I just saw that new movie everyone is talking about! Have you seen it?', 'Social', 'Medium', 'Share opinions about the movie', 'assets/images/scenes/movie_3d.png', 4294763756, 'en-US'),
  ('6ceebc99-9c0b-4ef8-bb6d-6bb9bd380a23', 'Seeing a Doctor', 'Describe your symptoms to a doctor', '🩺', 'Doctor', 'Patient', 'Hello. What seems to be the trouble today?', 'Daily Life', 'Hard', 'Explain your symptoms and get advice', 'assets/images/scenes/doctor_3d.png', 4292932337, 'en-US')
ON CONFLICT (id) DO NOTHING;



-- ============================================
-- 3. UPGRADE CUSTOM SCENARIOS TABLE
-- ============================================

ALTER TABLE custom_scenarios 
  ADD COLUMN IF NOT EXISTS origin_standard_id UUID, -- No FK, purely for history tracking
  ADD COLUMN IF NOT EXISTS source_type TEXT NOT NULL DEFAULT 'custom', -- 'standard' | 'custom'
  ADD COLUMN IF NOT EXISTS icon_path TEXT,
  ADD COLUMN IF NOT EXISTS color BIGINT DEFAULT 4294967295,
  ADD COLUMN IF NOT EXISTS target_language TEXT DEFAULT 'en-US', -- BCP-47
  ADD COLUMN IF NOT EXISTS goal TEXT DEFAULT '',
  ADD COLUMN IF NOT EXISTS emoji TEXT DEFAULT '🎭',
  ADD COLUMN IF NOT EXISTS difficulty TEXT DEFAULT 'Medium',
  ADD COLUMN IF NOT EXISTS category TEXT DEFAULT 'Custom';

-- Constraint: source_type must be 'standard' or 'custom'
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'custom_scenarios_source_type_check'
  ) THEN
    ALTER TABLE custom_scenarios ADD CONSTRAINT custom_scenarios_source_type_check 
      CHECK (source_type IN ('standard', 'custom'));
  END IF;
END $$;

-- Indexes
CREATE INDEX IF NOT EXISTS idx_custom_scenarios_origin ON custom_scenarios(origin_standard_id);
CREATE INDEX IF NOT EXISTS idx_custom_scenarios_source_type ON custom_scenarios(source_type);
CREATE INDEX IF NOT EXISTS idx_custom_scenarios_updated_user ON custom_scenarios(user_id, updated_at DESC);


-- ============================================
-- 4. FUNCTION & TRIGGER: AUTO-CLONE FOR NEW USERS
-- ============================================

CREATE OR REPLACE FUNCTION handle_new_user_scenes() 
RETURNS TRIGGER AS $$
BEGIN
  -- Insert all standard scenes into custom_scenarios for the new user
  INSERT INTO custom_scenarios (
    user_id,
    title,
    description,
    ai_role,
    user_role,
    initial_message,
    goal,
    emoji,
    category,
    difficulty,
    icon_path,
    color,
    target_language,
    origin_standard_id,
    source_type,
    updated_at -- Set updated_at with offset for predictable initial sort
  )
  SELECT 
    NEW.id, -- The new user's ID
    s.title,
    s.description,
    s.ai_role,
    s.user_role,
    s.initial_message,
    s.goal,
    s.emoji,
    s.category,
    s.difficulty,
    s.icon_path,
    s.color,
    s.target_language,
    s.id,
    'standard', -- Mark as cloned from standard
    -- Use ROW_NUMBER offset to maintain predictable initial order (first scene = newest)
    NOW() - (ROW_NUMBER() OVER (ORDER BY s.id) * INTERVAL '1 second')
  FROM standard_scenes s;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on auth.users
DROP TRIGGER IF EXISTS on_auth_user_created_scenes ON auth.users;
CREATE TRIGGER on_auth_user_created_scenes
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user_scenes();


-- ============================================
-- 5. ONE-OFF MIGRATION: SEED EXISTING USERS
-- ============================================

DO $$
DECLARE
  user_record RECORD;
BEGIN
  -- Loop through all existing users
  FOR user_record IN SELECT id FROM auth.users LOOP
    
    -- Insert standard scenes for this user IF they don't have them already
    INSERT INTO custom_scenarios (
      user_id,
      title,
      description,
      ai_role,
      user_role,
      initial_message,
      goal,
      emoji,
      category,
      difficulty,
      icon_path,
      color,
      target_language,
      origin_standard_id,
      source_type,
      updated_at
    )
    SELECT 
      user_record.id,
      s.title,
      s.description,
      s.ai_role,
      s.user_role,
      s.initial_message,
      s.goal,
      s.emoji,
      s.category,
      s.difficulty,
      s.icon_path,
      s.color,
      s.target_language,
      s.id,
      'standard', -- Mark as cloned from standard
      -- Use ROW_NUMBER offset to maintain predictable initial order (first scene = newest)
      NOW() - (ROW_NUMBER() OVER (ORDER BY s.id) * INTERVAL '1 second')
    FROM standard_scenes s
    WHERE NOT EXISTS (
      SELECT 1 FROM custom_scenarios cs 
      WHERE cs.user_id = user_record.id 
      AND cs.origin_standard_id = s.id
    );
    
  END LOOP;
END $$;
