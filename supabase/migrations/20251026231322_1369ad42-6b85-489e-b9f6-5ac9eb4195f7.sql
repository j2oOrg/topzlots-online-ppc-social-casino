-- Add xp_reward column to games table
ALTER TABLE public.games 
ADD COLUMN xp_reward INTEGER NOT NULL DEFAULT 50;

-- Update existing games with different XP values
UPDATE public.games SET xp_reward = 50 WHERE id = 1;
UPDATE public.games SET xp_reward = 75 WHERE id = 2;
UPDATE public.games SET xp_reward = 100 WHERE id = 3;
UPDATE public.games SET xp_reward = 60 WHERE id = 4;
UPDATE public.games SET xp_reward = 80 WHERE id = 5;