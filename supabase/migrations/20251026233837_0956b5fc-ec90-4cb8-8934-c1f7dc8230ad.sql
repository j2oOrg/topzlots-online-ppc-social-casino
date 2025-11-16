-- Fix security warning: set search_path for generate_invite_code function
CREATE OR REPLACE FUNCTION public.generate_invite_code()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
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