-- Add invite code and referral tracking to profiles
ALTER TABLE public.profiles
ADD COLUMN invite_code TEXT UNIQUE,
ADD COLUMN referred_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL;

-- Function to generate random invite code
CREATE OR REPLACE FUNCTION public.generate_invite_code()
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  code TEXT;
  done BOOLEAN := FALSE;
BEGIN
  WHILE NOT done LOOP
    -- Generate 8 character code with uppercase letters and numbers
    code := upper(substring(md5(random()::text || clock_timestamp()::text) from 1 for 8));
    
    -- Check if code already exists
    IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE invite_code = code) THEN
      done := TRUE;
    END IF;
  END LOOP;
  
  RETURN code;
END;
$$;

-- Update handle_new_user to generate invite code and handle referrals
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  referrer_id UUID;
  new_invite_code TEXT;
BEGIN
  -- Generate unique invite code
  new_invite_code := generate_invite_code();
  
  -- Check if user was referred by someone
  IF NEW.raw_user_meta_data->>'invite_code' IS NOT NULL THEN
    -- Find the referrer by their invite code
    SELECT id INTO referrer_id
    FROM public.profiles
    WHERE invite_code = NEW.raw_user_meta_data->>'invite_code';
    
    -- If referrer found, give them 200 XP
    IF referrer_id IS NOT NULL THEN
      UPDATE public.profiles
      SET experience = experience + 200
      WHERE id = referrer_id;
    END IF;
  END IF;
  
  -- Insert new profile with invite code and referrer
  INSERT INTO public.profiles (id, username, points, diamonds, current_level, experience, invite_code, referred_by)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', 'Player' || substr(NEW.id::text, 1, 8)),
    1000,
    0,
    1,
    0,
    new_invite_code,
    referrer_id
  );
  
  RETURN NEW;
END;
$$;

-- Backfill invite codes for existing users
UPDATE public.profiles
SET invite_code = generate_invite_code()
WHERE invite_code IS NULL;