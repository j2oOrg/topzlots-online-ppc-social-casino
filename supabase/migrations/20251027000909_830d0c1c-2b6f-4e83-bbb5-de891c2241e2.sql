-- Remove Alien Robots game
DELETE FROM public.games WHERE name = 'Alien Robots';

-- Insert Brilliants Hot game
INSERT INTO public.games (name, description, embed_code, thumbnail_url, xp_reward) VALUES
(
  'Brilliants Hot',
  'The Brilliants Hot video slot from the Casino Technology manufacturer is a combination of the classic approach and luxury. On the one hand, it is inspired by traditional one-armed bandits, and on the other, it is dedicated to gemstones. The user has a chance to receive payments with line coefficients up to x1000. Prizes can be increased during a doubling round. The game is played on five reels with 20 lines.',
  '<iframe src="https://free-slots.games/game/BrilliantsHotCT/" title="Brilliants Hot - free slot " width="640" height="480" ></iframe>',
  '/games/brilliants-hot.jpg',
  50
);