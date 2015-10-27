CREATE OR REPLACE FORCE VIEW MG_GAME_HIGHSCORES_VW
AS
SELECT trim(p.first_name || ' ' || p.last_name) player_name
     , g.play_date
     , (select sum(gr.score) from mg_game_rounds gr where gr.fk_game_id = g.pk_id) total_score
  FROM mg_players p, mg_games g
 WHERE g.finished = 1
   AND g.fk_player_id = p.pk_id
 ORDER BY total_score DESC
;
  