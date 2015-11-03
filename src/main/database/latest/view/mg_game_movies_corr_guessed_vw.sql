create or replace force view mg_game_movies_corr_guessed_vw as
  select null as link,
         m.title as label,
         count(*) as value
  from mg_movies m, mg_game_rounds gr, mg_guesses g
  where m.pk_id = gr.fk_movie_id
  and gr.pk_id = g.fk_game_round_id
  and g.correct = 1
  group by m.title;