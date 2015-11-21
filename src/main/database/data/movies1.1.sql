-- 807: Se7en
-- 613: Der Untergang
-- 637: Life Is Beautiful
update mg_movies
set active = 0
where tmdb_id in (807, 613, 637);

-- Life Of Brian --> Life of Brian
update mg_movies
set title = 'Life of Brian'
where tmdb_id = 583;

-- Life Of Pi --> Life of Pi
update mg_movies
set title = 'Life of Pi'
where tmdb_id = 87827;

-- Guardians Of The Galaxy --> Guardians of the Galaxy
update mg_movies
set title = 'Guardians of the Galaxy'
where tmdb_id = 118340;

-- Back To The Future --> Back to the Future
update mg_movies
set title = 'Back to the Future'
where tmdb_id = 105;

-- Raiders Of The Lost Ark --> Raiders of the Lost Ark
update mg_movies
set title = 'Raiders of the Lost Ark'
where tmdb_id = 85;

-- Ben Hur --> Ben-Hur
update mg_movies
set title = 'Ben-Hur'
where tmdb_id = 665;

-- A Knights Tale --> A Knight's Tale
update mg_movies
set title = 'A Knight''s Tale'
where tmdb_id = 9476;

-- The Kings Speech --> The King's Speech
update mg_movies
set title = 'The King''s Speech'
where tmdb_id = 45269;

-- No Country For Old Men --> No Country for Old Men
update mg_movies
set title = 'No Country for Old Men'
where tmdb_id = 6977;

-- new movies
insert into mg_movies (tmdb_id, title, active) values ('9740', 'Hannibal', 1);
insert into mg_movies (tmdb_id, title, active) values ('462', 'Erin Brockovich', 1);
insert into mg_movies (tmdb_id, title, active) values ('377', 'A Nightmare on Elm Street', 1);
insert into mg_movies (tmdb_id, title, active) values ('9552', 'The Exorcist', 1);