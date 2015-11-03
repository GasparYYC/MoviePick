alter table mg_game_rounds
drop column finished;

alter table mg_game_rounds
modify (score not null);