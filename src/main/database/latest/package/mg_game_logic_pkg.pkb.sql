create or replace package body mg_game_logic_pkg is

  function game_rounds_coll_name
  return apex_collections.collection_name%type result_cache is
  begin
    return 'GAME_ROUNDS';
  end game_rounds_coll_name;


  function game_rounds_view_name
  return user_views.view_name%type result_cache is
  begin
    return 'MG_GAME_ROUNDS_COLL_VW';
  end game_rounds_view_name;


  function game_round_guesses_coll_name
  return apex_collections.collection_name%type result_cache is
  begin
    return 'GAME_ROUND_GUESSES';
  end game_round_guesses_coll_name;


  function current_game_round_number
  return mg_game_rounds_coll_vw.game_round_number%type is
    l_current_game_round_number mg_game_rounds_coll_vw.game_round_number%type;
  begin
    l_current_game_round_number := apex_collection.collection_member_count(
                                     p_collection_name => game_rounds_coll_name
                                   );

    return l_current_game_round_number;
  end current_game_round_number;


  function current_game_round_score
  return mg_game_rounds_coll_vw.score%type is
    l_current_game_round_score mg_game_rounds_coll_vw.score%type;
  begin
    select score
    into l_current_game_round_score
    from mg_game_rounds_coll_vw
    where game_round_number = current_game_round_number;

    return l_current_game_round_score;
  end current_game_round_score;


  function current_game_round_movie_title
  return mg_game_rounds_coll_vw.title%type is
    l_movie_title mg_game_rounds_coll_vw.title%type;
  begin
    select title
    into l_movie_title
    from mg_game_rounds_coll_vw
    where game_round_number = current_game_round_number;

    return l_movie_title;
  end current_game_round_movie_title;


  function current_game_round
  return mg_game_rounds_coll_vw%rowtype is
    lr_current_game_round mg_game_rounds_coll_vw%rowtype;
  begin
    select *
    into lr_current_game_round
    from mg_game_rounds_coll_vw
    where game_round_number = current_game_round_number;

    return lr_current_game_round;
  end current_game_round;


  function current_total_game_score
  return mg_game_rounds.score%type is
    l_current_total_game_score mg_game_rounds.score%type;
  begin
    select nvl(sum(score), 0)
    into l_current_total_game_score
    from mg_game_rounds_coll_vw;

    return l_current_total_game_score;
  end current_total_game_score;


  procedure lower_game_round_score(
    in_minus_points in mg_hint_types.hint_cost%type
  ) is
    l_new_score mg_game_rounds_coll_vw.score%type;
  begin
    l_new_score := current_game_round_score - in_minus_points;

    if sign(l_new_score) = -1 then
      l_new_score := 0;
    end if;

    apex_collection.update_member_attribute(
      p_collection_name => game_rounds_coll_name,
      p_seq => current_game_round_number,
      p_attr_number => '1',
      p_number_value => l_new_score
    );
  end lower_game_round_score;


  procedure init_game is
  begin
    apex_collection.create_or_truncate_collection(
      p_collection_name => game_rounds_coll_name
    );

    apex_collection.create_or_truncate_collection(
      p_collection_name => mg_hints_pkg.game_round_hints_coll_name
    );

    apex_collection.create_or_truncate_collection(
      p_collection_name => game_round_guesses_coll_name
    );
  end init_game;


  procedure init_game_round is
    lco_initial_score constant mg_game_rounds_coll_vw.score%type := 200;
    lco_max_game_rounds constant mg_game_rounds_coll_vw.game_round_number%type := 5;

    l_random_tmdb_id mg_movies.tmdb_id%type;
    l_masked_movie_title mg_game_rounds_coll_vw.title%type;
    l_character_hint_cost mg_hint_types.hint_cost%type;
  begin
    if current_game_round_number < lco_max_game_rounds then
      l_random_tmdb_id := mg_movies_pkg.random_tmdb_id;

      mg_tmdb_api_pkg.movie_data_to_collection(
        in_tmdb_id => l_random_tmdb_id
      );

      apex_collection.update_member_attribute(
        p_collection_name => game_rounds_coll_name,
        p_seq => current_game_round_number,
        p_attr_number => '1',
        p_number_value => lco_initial_score
      );

      l_masked_movie_title := mg_movies_pkg.masked_movie_title(
                                in_movie_title => current_game_round_movie_title
                              );

      l_character_hint_cost := mg_hints_pkg.calculate_character_hint_cost(
                                 in_movie_title => current_game_round_movie_title
                               );

      apex_collection.update_member_attribute(
        p_collection_name => game_rounds_coll_name,
        p_seq => current_game_round_number,
        p_attr_number => '2',
        p_number_value => l_character_hint_cost
      );
    else
      l_masked_movie_title := 'X';
      l_character_hint_cost := 0;
    end if;

    apex_json.open_object;
    apex_json.write('maskedMovieTitle', l_masked_movie_title);
    apex_json.write('characterHintCost', l_character_hint_cost);
    apex_json.close_object;
  end init_game_round;


  procedure validate_guess(
    in_guess in varchar2
  ) is
    lco_cost_of_wrong_guess constant mg_game_rounds_coll_vw.game_round_number%type := 10;
    lco_max_game_rounds constant mg_game_rounds_coll_vw.game_round_number%type := 5;

    lr_current_game_round mg_game_rounds_coll_vw%rowtype;
    l_is_correct_guess boolean;
    l_is_end_of_game boolean;

    function boolean_as_number(
      in_boolean_value in boolean
    ) return mg_guesses.correct%type is
      l_boolean_as_number mg_guesses.correct%type;
    begin
      if in_boolean_value then
        l_boolean_as_number := 1;
      else
        l_boolean_as_number := 0;
      end if;

      return l_boolean_as_number;
    end boolean_as_number;
  begin
    lr_current_game_round := current_game_round;

    l_is_correct_guess := lower(replace(lr_current_game_round.title, ' ', '')) = lower(in_guess);

    -- save guess to collection
    apex_collection.add_member(
      p_collection_name => game_round_guesses_coll_name,
      p_c001 => lr_current_game_round.game_round_number,
      p_c002 => in_guess,
      p_c003 => boolean_as_number(l_is_correct_guess)
    );

    if l_is_correct_guess then
      if lr_current_game_round.game_round_number = lco_max_game_rounds then
        l_is_end_of_game := true;
      else
        l_is_end_of_game := false;
      end if;
    else
      -- subtract points for wrong guess
      lower_game_round_score(
        in_minus_points => lco_cost_of_wrong_guess
      );

      l_is_correct_guess := false;
      l_is_end_of_game := false;
    end if;

    apex_json.open_object;
    apex_json.write('isCorrectGuess', l_is_correct_guess);
    apex_json.write('isEndOfGame', l_is_end_of_game);
    if l_is_correct_guess then
      apex_json.write('moviePoster', lr_current_game_round.poster);
      apex_json.write('gameRoundScore', lr_current_game_round.score);
      apex_json.write('totalGameScore', current_total_game_score);
    end if;
    apex_json.close_object;
  end validate_guess;


  procedure give_up is
    lco_max_game_rounds constant mg_game_rounds_coll_vw.game_round_number%type := 5;

    lr_current_game_round mg_game_rounds_coll_vw%rowtype;
    l_is_end_of_game boolean;
  begin
    lr_current_game_round := current_game_round;

    if lr_current_game_round.game_round_number = lco_max_game_rounds then
      l_is_end_of_game := true;
    else
      l_is_end_of_game := false;
    end if;

    lower_game_round_score(
      in_minus_points => 1000
    );

    apex_json.open_object;
    apex_json.write('isEndOfGame', l_is_end_of_game);
    apex_json.write('moviePoster', lr_current_game_round.poster);
    apex_json.write('gameRoundScore', current_game_round_score); -- don't use the LR_CURRENT_GAME_ROUND record variable
    apex_json.write('totalGameScore', current_total_game_score);
    apex_json.close_object;
  end give_up;


  procedure collections_to_tables(
    in_player_name in mg_players.name%type
  ) is
    cursor lcu_game_rounds is
      select game_round_number,
             score,
             tmdb_id
      from mg_game_rounds_coll_vw;

    l_player_id mg_players.pk_id%type;
    l_game_id mg_games.pk_id%type;
    l_game_round_id mg_game_rounds.pk_id%type;
    l_movie_id mg_games.pk_id%type;
  begin
    insert into mg_players (name)
    values (nvl(in_player_name, 'Anonymous'))
    returning pk_id into l_player_id;

    insert into mg_games (play_date, fk_player_id)
    values (sysdate, l_player_id)
    returning pk_id into l_game_id;

    for rec_game_round in lcu_game_rounds loop
      l_movie_id := mg_movies_pkg.movie_id_by_tmdb_id(
                      in_tmdb_id => rec_game_round.tmdb_id
                    );

      insert into mg_game_rounds (seq_id, score, fk_game_id, fk_movie_id)
      values (rec_game_round.game_round_number, rec_game_round.score, l_game_id, l_movie_id)
      returning pk_id into l_game_round_id;

      insert into mg_game_round_hints (seq_id, fk_game_round_id, fk_hint_type_id)
      select rownum,
             l_game_round_id,
             hint_type
      from (select mg_hints_pkg.hint_type_id_by_code_id(hint_type) as hint_type
            from mg_game_round_hints_coll_vw
            where game_round_number = rec_game_round.game_round_number
            order by seq_id) hints_coll_vw;

      insert into mg_guesses (seq_id, guess, correct, fk_game_round_id)
      select rownum,
             nvl(guess, ' '),
             to_number(correct),
             l_game_round_id
      from (select guess,
                   correct
            from mg_game_round_guesses_coll_vw
            where game_round_number = rec_game_round.game_round_number
            order by seq_id) guesses_coll_vw;
    end loop;
  end collections_to_tables;

end mg_game_logic_pkg;