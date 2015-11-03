create table mg_guesses(
  pk_id number not null,
  seq_id number not null,
  guess varchar2(255) not null,
  correct number(1) not null,
  fk_game_round_id number not null,
  created_by varchar2(100) not null,
  created_on date not null,
  last_updated_by varchar2(100),
  last_updated_on date
);

create index mg_guesses_game_round_id_idx on mg_guesses (fk_game_round_id asc);
alter table mg_guesses add constraint mg_guesses_pk primary key (pk_id);
alter table mg_guesses add constraint mg_guesses_game_rounds_fk foreign key (fk_game_round_id) references mg_game_rounds (pk_id);