create or replace force view mg_game_highscores_vw as
  select rownum as rank,
         highscores.*
  from (
    select trim(p.name) as player_name,
           (select sum(gr.score)
            from mg_game_rounds gr
            where gr.fk_game_id = g.pk_id) as total_score,
           (select count(*)
            from mg_game_round_hints grh, mg_game_rounds gr
            where gr.fk_game_id = g.pk_id
            and gr.pk_id = grh.fk_game_round_id) as total_nbr_hints,
           (select count(*)
            from mg_games game
            join mg_game_rounds round on game.pk_id = round.fk_game_id
            left join mg_guesses guess on round.pk_id = guess.fk_game_round_id
            where game.pk_id = g.pk_id
            and guess.correct = 0) as total_nbr_guesses,
           g.play_date
    from mg_players p, mg_games g
    where g.fk_player_id = p.pk_id
    order by total_score desc
  ) highscores;