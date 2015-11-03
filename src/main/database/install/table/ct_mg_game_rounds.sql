create table mg_game_rounds(
  pk_id number not null,
  seq_id number not null,
  score number,
  finished number(1),
  fk_game_id number not null,
  fk_movie_id number not null,
  created_by varchar2(100) not null,
  created_on date not null,
  last_updated_by varchar2(100),
  last_updated_on date
);

create index mg_game_rounds_game_id_idx on mg_game_rounds (fk_game_id asc);
create index mg_game_rounds_movie_id_idx on mg_game_rounds (fk_movie_id asc);
alter table mg_game_rounds add constraint mg_game_rounds_pk primary key (pk_id);
alter table mg_game_rounds add constraint mg_game_rounds_games_fk foreign key (fk_game_id) references mg_games (pk_id);
alter table mg_game_rounds add constraint mg_game_rounds_movies_fk foreign key (fk_movie_id) references mg_movies (pk_id);