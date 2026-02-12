INSERT INTO profiles (id, first_name, last_name, floor, apartment_number, role) VALUES
-- ETAGE 1
(gen_random_uuid(), 'Adnan', 'Ayazi', 1, 1, 'resident'),
(gen_random_uuid(), 'Fatima', 'Dehbi', 1, 2, 'resident'),
(gen_random_uuid(), 'Nora', 'Mouktadi', 1, 3, 'resident'),
(gen_random_uuid(), 'Annan', 'Jalila', 1, 4, 'resident'),
(gen_random_uuid(), 'Sbai', 'Yahya', 1, 5, 'resident'),

-- ETAGE 2
(gen_random_uuid(), 'Yasmine', 'Boukherssa', 2, 6, 'resident'),
(gen_random_uuid(), 'Jalal', 'Liassini', 2, 7, 'resident'),
(gen_random_uuid(), 'Abdelati', 'Kenbouchi', 2, 8, 'syndic'), -- LE SYNDIC
(gen_random_uuid(), 'Sbaili', 'Marwa', 2, 9, 'resident'),
(gen_random_uuid(), 'Bessam', 'Halil', 2, 10, 'resident'),

-- ETAGE 3
(gen_random_uuid(), 'Adil', 'Rahil', 3, 11, 'resident'),
(gen_random_uuid(), 'Mohsine', 'Arif', 3, 12, 'resident'),
(gen_random_uuid(), 'Asmaa', 'Oualad', 3, 13, 'resident'),
(gen_random_uuid(), 'Naoual', 'Fidar', 3, 14, 'resident'),
(gen_random_uuid(), 'Kawtar', 'Es-Saidi', 3, 15, 'resident'),

-- STAFF (Hors Appartements)
(gen_random_uuid(), 'Badr', 'Daby', 0, 0, 'adjoint'),
(gen_random_uuid(), 'Gardien', 'Principal', 0, 0, 'concierge');
