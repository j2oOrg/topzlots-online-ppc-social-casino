-- Update profile_frames image URLs to match actual files in public folder
UPDATE profile_frames SET image_url = '/frames/bronze-metal.png' WHERE id = 1;
UPDATE profile_frames SET image_url = '/frames/silver-metal.png' WHERE id = 2;
UPDATE profile_frames SET image_url = '/frames/golden-ornate.png' WHERE id = 3;
UPDATE profile_frames SET image_url = '/frames/platinum-metal.png' WHERE id = 4;
UPDATE profile_frames SET image_url = '/frames/crystal-diamond.png' WHERE id = 5;
UPDATE profile_frames SET image_url = '/frames/ruby-gem.png' WHERE id = 6;
UPDATE profile_frames SET image_url = '/frames/sapphire-gem.png' WHERE id = 7;
UPDATE profile_frames SET image_url = '/frames/emerald-gem.png' WHERE id = 8;
UPDATE profile_frames SET image_url = '/frames/legendary-epic.png' WHERE id = 9;
UPDATE profile_frames SET image_url = '/frames/mythic-cosmic.png' WHERE id = 10;