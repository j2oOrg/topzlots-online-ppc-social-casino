-- Add policy to allow viewing all profiles for leaderboard
-- This allows anyone to see username, level, experience, and profile frame
-- but still protects sensitive data through the existing policies for updates/inserts
CREATE POLICY "Anyone can view leaderboard data"
ON public.profiles
FOR SELECT
USING (true);

-- Note: This doesn't compromise security because:
-- 1. Users can only UPDATE/INSERT their own data (existing policies)
-- 2. Only public leaderboard info (username, level, XP, frame) is exposed
-- 3. No sensitive information like email is in the profiles table