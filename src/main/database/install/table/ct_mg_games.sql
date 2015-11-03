create table mg_games(
  pk_id number not null,
  play_date date not null,
  finished number(1) not null,
  fk_player_id number not null,
  created_by varchar2(100) not null,
  created_on date not null,
  last_updated_by varchar2(100),
  last_updated_on date
);

create index mg_games_player_id_idx on mg_games (fk_player_id asc);
alter table mg_games add constraint mg_games_pk primary key (pk_id);
alter table mg_games add constraint mg_games_players_fk foreign key (fk_player_id) references mg_players (pk_id);