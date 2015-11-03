create table mg_game_round_hints(
  pk_id number not null,
  seq_id number not null,
  fk_game_round_id number not null,
  fk_hint_type_id number not null
);

create index mg_grh_game_round_id_idx on mg_game_round_hints (fk_game_round_id asc);
create index mg_grh_hint_type_id_idx on mg_game_round_hints (fk_hint_type_id asc);
alter table mg_game_round_hints add constraint mg_game_round_hints_pk primary key (pk_id);
alter table mg_game_round_hints add constraint mg_round_hints_game_rounds_fk foreign key (fk_game_round_id) references mg_game_rounds (pk_id);
alter table mg_game_round_hints add constraint mg_round_hints_hint_types_fk foreign key (fk_hint_type_id) references mg_hint_types (pk_id);