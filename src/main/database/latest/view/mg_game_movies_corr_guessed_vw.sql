CREATE OR REPLACE FORCE VIEW MG_GAME_MOVIES_CORR_GUESSED_VW
AS
select null as link
     , m.title as label
     , count(1) as value
  from mg_movies m, mg_game_rounds gr, mg_guesses g
 where m.pk_id = gr.fk_movie_id
   and gr.pk_id = g.fk_game_round_id
   and g.correct = 1
 group by m.title
;