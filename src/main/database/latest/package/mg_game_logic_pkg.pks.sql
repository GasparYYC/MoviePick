create or replace package mg_game_logic_pkg is

  function game_rounds_coll_name
  return apex_collections.collection_name%type result_cache;

  function game_rounds_view_name
  return user_views.view_name%type result_cache;


  function current_game_round_number
  return mg_game_rounds_coll_vw.game_round_number%type;

  function current_game_round_score
  return mg_game_rounds_coll_vw.score%type;

  function current_game_round_movie_title
  return mg_game_rounds_coll_vw.title%type;

  function current_game_round
  return mg_game_rounds_coll_vw%rowtype;

  function current_total_game_score
  return mg_game_rounds.score%type;

  procedure lower_game_round_score(
    in_minus_points in mg_hint_types.hint_cost%type
  );


  procedure init_game;

  procedure init_game_round;

  procedure validate_guess(
    in_guess in varchar2
  );

  procedure give_up;

  procedure collections_to_tables(
    in_player_name in mg_players.name%type
  );

end mg_game_logic_pkg;