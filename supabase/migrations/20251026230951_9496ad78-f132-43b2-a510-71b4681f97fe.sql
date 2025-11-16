-- Create table to track game visits
CREATE TABLE public.game_visits (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  game_id INTEGER NOT NULL,
  last_visit_date DATE NOT NULL DEFAULT CURRENT_DATE,
  visit_count INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(user_id, game_id)
);

-- Enable RLS
ALTER TABLE public.game_visits ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own game visits"
ON public.game_visits
FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own game visits"
ON public.game_visits
FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own game visits"
ON public.game_visits
FOR UPDATE
USING (auth.uid() = user_id);

-- Add trigger for updated_at
CREATE TRIGGER update_game_visits_updated_at
BEFORE UPDATE ON public.game_visits
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Create index for faster lookups
CREATE INDEX idx_game_visits_user_game ON public.game_visits(user_id, game_id);
CREATE INDEX idx_game_visits_date ON public.game_visits(last_visit_date);