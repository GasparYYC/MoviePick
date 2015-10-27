CREATE OR REPLACE FORCE VIEW MG_GAME_HIGHSCORES_VW
AS
SELECT trim(p.first_name || ' ' || p.last_name) player_name
     , g.play_date
     , (select sum(gr.score) from mg_game_rounds gr where gr.fk_game_id = g.pk_id) total_score
     , (select count(1) from mg_game_round_hints grh, mg_game_rounds gr where gr.fk_game_id = g.pk_id and gr.pk_id = grh.fk_game_round_id) total_nbr_hints
     , (select sum(hint_cost) from mg_hint_types ht, mg_game_round_hints grh, mg_game_rounds gr where gr.fk_game_id = g.pk_id and gr.pk_id = grh.fk_game_round_id and grh.fk_hint_type_id = ht.pk_id) total_hint_cost
  FROM mg_players p, mg_games g
 WHERE g.finished = 1
   AND g.fk_player_id = p.pk_id
 ORDER BY total_score DESC
;
  