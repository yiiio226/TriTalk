-- Migration: Create standard_scenes table and seed data
-- Created based on docs/standard_scenes_migration_plan.md

-- 1. Create Table
CREATE TABLE IF NOT EXISTS standard_scenes (
  id TEXT PRIMARY KEY,
  
  -- Core Content
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  ai_role TEXT NOT NULL,
  user_role TEXT NOT NULL,
  initial_message TEXT NOT NULL,
  goal TEXT NOT NULL,
  
  -- Metadata
  emoji TEXT NOT NULL DEFAULT '🎭',
  category TEXT NOT NULL,
  difficulty TEXT NOT NULL,
  icon_path TEXT,
  color INTEGER NOT NULL,
  
  -- Language & Management
  target_language TEXT NOT NULL DEFAULT 'English',
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Create Indexes
CREATE INDEX IF NOT EXISTS idx_standard_scenes_language ON standard_scenes(target_language);
CREATE INDEX IF NOT EXISTS idx_standard_scenes_order ON standard_scenes(display_order);

-- 3. Enable RLS
ALTER TABLE standard_scenes ENABLE ROW LEVEL SECURITY;

-- 4. Create Policies
-- Publicly readable if active
CREATE POLICY "Standard scenes are publicly readable" 
  ON standard_scenes FOR SELECT 
  USING (is_active = true);

-- Only admin/service_role can insert/update/delete (implicit default deny for others)

-- 5. Add Update Trigger
DROP TRIGGER IF EXISTS update_standard_scenes_updated_at ON standard_scenes;
CREATE TRIGGER update_standard_scenes_updated_at
  BEFORE UPDATE ON standard_scenes
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 6. Seed Data (Converted from mock_scenes.dart)
-- Note: colors are converted from 0xAARRGGBB to Signed 32-bit Integer or stored as BigInt. 
-- Flutter Color(0xFFE0F2F1).value is 4292932337.
-- Postgres INTEGER is signed 32-bit (max 2147483647). 
-- 0xFFE0F2F1 (4292932337) overflows standard integer. 
-- We should verify if 'color' column should be BIGINT or if we store the ARGB int value.
-- In Flutter, Color(int) takes an int. Dart ints are 64-bit.
-- Let's change column type to BIGINT to be safe for 0xFF format.

ALTER TABLE standard_scenes ALTER COLUMN color TYPE BIGINT;

INSERT INTO standard_scenes (id, title, description, emoji, ai_role, user_role, initial_message, category, difficulty, goal, icon_path, color, target_language, display_order)
VALUES
  ('s1', 'Order Coffee', 'Order a coffee', '☕', 'Barista', 'Customer', 'Hi! What can I get for you today?', 'Daily Life', 'Easy', 'Order a coffee', 'assets/images/scenes/coffee_3d.png', 4292932337, 'English', 1),
  
  ('s2', 'Check-in at Immigration', 'Answer questions and get through immigration', '✈️', 'Immigration Officer', 'Traveler', 'Good morning. May I see your passport?', 'Travel', 'Medium', 'Answer questions and get through immigration', 'assets/images/scenes/plane_3d.png', 4294965473, 'English', 2),
  
  ('s3', 'Lost Wallet', 'Ask for help finding your wallet', '👛', 'Helpful Stranger', 'Person who lost wallet', 'Excuse me, you look worried. Is everything okay?', 'Emergency', 'Hard', 'Ask for help finding your wallet', 'assets/images/scenes/wallet_3d.png', 4294962158, 'English', 3),
  
  ('s4', 'Taking a Taxi', 'Give directions to the driver', 'kB', 'Taxi Driver', 'Passenger', 'Hello! Where are you heading to today?', 'Daily Life', 'Easy', 'Reach your destination', 'assets/images/scenes/taxi_3d.png', 4294964192, 'English', 4),
  
  ('s5', 'Supermarket Shopping', 'Ask where to find items', '🛒', 'Supermarket Staff', 'Customer', 'Hi there! Can I help you find anything?', 'Daily Life', 'Easy', 'Find all items on your list', 'assets/images/scenes/supermarket_3d.png', 4293457385, 'English', 5),
  
  ('s6', 'Asking for Directions', 'Ask a local for directions', '🗺️', 'Local', 'Lost Traveler', 'Hello! Do you need some help finding your way?', 'Travel', 'Medium', 'Find the way to your destination', 'assets/images/scenes/map_3d.png', 4293128957, 'English', 6),
  
  ('s7', 'First Meeting', 'Introduce yourself to a new friend', '🤝', 'New Friend', 'Self', 'Hi! Nice to meet you. I''m Alex.', 'Social', 'Easy', 'Get to know each other', 'assets/images/scenes/handshake_3d.png', 4294190581, 'English', 7),
  
  ('s8', 'Hotel Check-in', 'Check in to your hotel room', '🏨', 'Receptionist', 'Guest', 'Welcome! Do you have a reservation with us?', 'Travel', 'Medium', 'Successfully check in', 'assets/images/scenes/hotel_3d.png', 4292937722, 'English', 8),
  
  ('s9', 'Restaurant Ordering', 'Order food at a restaurant', '🍽️', 'Waiter', 'Customer', 'Good evening. Here is the menu. Are you ready to order?', 'Daily Life', 'Medium', 'Order your meal', 'assets/images/scenes/food_3d.png', 4294703591, 'English', 9),
  
  ('s10', 'Job Interview', 'Answer interview questions', '💼', 'Interviewer', 'Candidate', 'Thank you for coming in through. Tell me a bit about yourself.', 'Business', 'Hard', 'Impress the interviewer', 'assets/images/scenes/interview_3d.png', 4293717937, 'English', 10),
  
  ('s11', 'Business Meeting', 'Discuss a project with colleagues', '📊', 'Colleague', 'Project Manager', 'Shall we get started with the project update?', 'Business', 'Hard', 'Coordinate the project next steps', 'assets/images/scenes/meeting_3d.png', 4293454582, 'English', 11),
  
  ('s12', 'Movie Discussion', 'Talk about a movie you saw', '🎬', 'Friend', 'Self', 'I just saw that new movie everyone is talking about! Have you seen it?', 'Social', 'Medium', 'Share opinions about the movie', 'assets/images/scenes/movie_3d.png', 4294763756, 'English', 12),
  
  ('s13', 'Seeing a Doctor', 'Describe your symptoms to a doctor', '🩺', 'Doctor', 'Patient', 'Hello. What seems to be the trouble today?', 'Daily Life', 'Hard', 'Explain your symptoms and get advice', 'assets/images/scenes/doctor_3d.png', 4292932337, 'English', 13)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  ai_role = EXCLUDED.ai_role,
  user_role = EXCLUDED.user_role,
  initial_message = EXCLUDED.initial_message,
  goal = EXCLUDED.goal,
  emoji = EXCLUDED.emoji,
  category = EXCLUDED.category,
  difficulty = EXCLUDED.difficulty,
  icon_path = EXCLUDED.icon_path,
  color = EXCLUDED.color,
  target_language = EXCLUDED.target_language,
  display_order = EXCLUDED.display_order;
