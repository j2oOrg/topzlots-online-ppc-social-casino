-- Make Bronze frame free (0 diamonds)
UPDATE public.profile_frames 
SET diamond_cost = 0 
WHERE id = 1;