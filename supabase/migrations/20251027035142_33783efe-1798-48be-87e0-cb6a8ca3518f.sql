-- Allow anyone to view check-in streaks for leaderboard display
CREATE POLICY "Anyone can view checkin streaks for leaderboard"
ON daily_checkins
FOR SELECT
USING (true);