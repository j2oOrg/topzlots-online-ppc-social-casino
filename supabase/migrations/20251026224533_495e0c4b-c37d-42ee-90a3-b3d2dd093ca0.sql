-- Create profiles table
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE,
  points INTEGER DEFAULT 1000 NOT NULL,
  diamonds INTEGER DEFAULT 0 NOT NULL,
  current_level INTEGER DEFAULT 1 NOT NULL,
  experience INTEGER DEFAULT 0 NOT NULL,
  profile_frame_id INTEGER DEFAULT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Create daily_checkins table
CREATE TABLE public.daily_checkins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  last_checkin_date DATE NOT NULL,
  consecutive_days INTEGER DEFAULT 1 NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  UNIQUE(user_id)
);

-- Create profile_frames table
CREATE TABLE public.profile_frames (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  diamond_cost INTEGER NOT NULL,
  image_url TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Create user_frames table (tracks which frames users have unlocked)
CREATE TABLE public.user_frames (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  frame_id INTEGER REFERENCES public.profile_frames(id) ON DELETE CASCADE NOT NULL,
  unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  UNIQUE(user_id, frame_id)
);

-- Create games table
CREATE TABLE public.games (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  embed_code TEXT NOT NULL,
  thumbnail_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_checkins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profile_frames ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_frames ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.games ENABLE ROW LEVEL SECURITY;

-- RLS Policies for profiles
CREATE POLICY "Users can view their own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- RLS Policies for daily_checkins
CREATE POLICY "Users can view their own checkins"
  ON public.daily_checkins FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can manage their own checkins"
  ON public.daily_checkins FOR ALL
  USING (auth.uid() = user_id);

-- RLS Policies for profile_frames (public read)
CREATE POLICY "Anyone can view frames"
  ON public.profile_frames FOR SELECT
  USING (true);

-- RLS Policies for user_frames
CREATE POLICY "Users can view their own frames"
  ON public.user_frames FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can manage their own frames"
  ON public.user_frames FOR ALL
  USING (auth.uid() = user_id);

-- RLS Policies for games (public read)
CREATE POLICY "Anyone can view games"
  ON public.games FOR SELECT
  USING (true);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_daily_checkins_updated_at
  BEFORE UPDATE ON public.daily_checkins
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Insert initial profile frames (10 frames with doubling diamond costs)
INSERT INTO public.profile_frames (name, diamond_cost, image_url) VALUES
  ('Bronze Frame', 1, '/frames/bronze.png'),
  ('Silver Frame', 2, '/frames/silver.png'),
  ('Gold Frame', 4, '/frames/gold.png'),
  ('Platinum Frame', 8, '/frames/platinum.png'),
  ('Diamond Frame', 16, '/frames/diamond.png'),
  ('Ruby Frame', 32, '/frames/ruby.png'),
  ('Sapphire Frame', 64, '/frames/sapphire.png'),
  ('Emerald Frame', 128, '/frames/emerald.png'),
  ('Legendary Frame', 256, '/frames/legendary.png'),
  ('Mythic Frame', 512, '/frames/mythic.png');

-- Insert initial games
INSERT INTO public.games (name, description, embed_code, thumbnail_url) VALUES
  ('Lord of the Ocean', 'The Lord of the Ocean slot is one of the best developments of Greentube on the marine topic. The game invites you to go on a trip to the ocean on 5 reels with 10 adjustable paylines. Each spin can bring you the winnings with the multipliers of up to 9,000.', '<iframe src="https://free-slots.games/greenslots/LordOfTheOcean/index.php" title="Lord of the Ocean - free slot " width="100%" height="600" frameborder="0"></iframe>', '/games/lord-ocean.jpg'),
  ('Columbus Deluxe', 'The Columbus Deluxe video slot invites you to go on an exciting journey. This is a popular historical game from Greentube, which has 5 reels and 10 adjustable paylines.', '<iframe src="https://free-slots.games/greenslots/ColumbusDX/index.php" title="Columbus Deluxe GreenTube - free slot " width="100%" height="600" frameborder="0"></iframe>', '/games/columbus.jpg'),
  ('Ancient Forest', 'The Ancient Forest video slot invites you to get acquainted with fairy-tale characters and allows you to get winnings with the coefficients of up to 2,000 per round. The slot has 5 reels, and you can activate from 1 to 10 lines.', '<iframe src="https://free-slots.games/greenslots/AncientForest/index.php" title="Ancient Forest - free slot " width="100%" height="600" frameborder="0"></iframe>', '/games/ancient-forest.jpg'),
  ('Age of Privateers', 'The Age of Privateers video slot is dedicated to the marine theme. This is an adventure game from Greentube, which invites you to go on a journey for generous winnings with the crew of a pirate ship.', '<iframe src="https://free-slots.games/greenslots/AgeOfPrivateers/index.php" title="Age of Privateers - free slot " width="100%" height="600" frameborder="0"></iframe>', '/games/privateers.jpg'),
  ('Alchemist''s Secret', 'The Alchemist''s Secret video slot is a great chance to experience the magic of gambling. The slot from Greentube is dedicated to the medieval wizards. It has 5 reels with 25 adjustable lines.', '<iframe src="https://free-slots.games/greenslots/AlchemistsSecret/index.php" title="Alchemist''s Secret - free slot " width="100%" height="600" frameborder="0"></iframe>', '/games/alchemist.jpg');

-- Function to handle new user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, points, diamonds, current_level, experience)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', 'Player' || substr(NEW.id::text, 1, 8)),
    1000,
    0,
    1,
    0
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Trigger to create profile on signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();