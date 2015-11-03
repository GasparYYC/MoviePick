create or replace package mg_hints_pkg is

  type grt_actor_hint is record(
    actor_name apex_collections.c010%type,
    actor_photo apex_collections.c011%type
  );


  function game_round_hints_coll_name
  return apex_collections.collection_name%type result_cache;


  function current_character_hint_cost
  return mg_game_rounds_coll_vw.character_hint_cost%type;


  procedure show_hint(
    in_hint_type in mg_hint_types.code_id%type
  );

  procedure show_actor_hint(
    in_hint_type in mg_hint_types.code_id%type
  );

  procedure show_character_hint(
    in_hint_type in mg_hint_types.code_id%type
  );

  function calculate_character_hint_cost(
    in_movie_title in mg_movies.title%type
  ) return mg_hint_types.hint_cost%type;

  function hint_type_id_by_code_id(
    in_code_id in mg_hint_types.code_id%type
  ) return mg_hint_types.pk_id%type;

end mg_hints_pkg;