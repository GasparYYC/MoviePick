alter table mg_players
drop column first_name;

alter table mg_players
drop column last_name;

alter table mg_players
add (name varchar2(255) not null);