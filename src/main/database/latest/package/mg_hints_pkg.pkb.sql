create or replace package body mg_hints_pkg is

  /* PRIVATE */

  function hint_type_id_by_code_id(
    in_hint_type in mg_hint_types.code_id%type
  ) return mg_hint_types.pk_id%type is
    l_hint_type_id mg_hint_types.pk_id%type;
  begin
    select pk_id
    into l_hint_type_id
    from mg_hint_types
    where upper(code_id) = upper(in_hint_type);

    return l_hint_type_id;
  end hint_type_id_by_code_id;


  function is_valid_hint_type(
    in_hint_type in mg_hint_types.code_id%type
  ) return boolean is
    l_hint_type_count number;
    l_is_valid_hint_type boolean;
  begin
    select count(*)
    into l_hint_type_count
    from mg_hint_types
    where upper(code_id) = upper(in_hint_type);

    if l_hint_type_count = 1 then
      l_is_valid_hint_type := true;
    else
      l_is_valid_hint_type := false;
    end if;

    return l_is_valid_hint_type;
  end is_valid_hint_type;


  function next_game_round_hint_seq_id(
    in_game_round_id in mg_game_rounds.pk_id%type
  ) return mg_game_round_hints.seq_id%type is
    l_next_game_round_hint_seq_id mg_game_round_hints.seq_id%type;
  begin
    select nvl(max(seq_id), 0) + 1
    into l_next_game_round_hint_seq_id
    from mg_game_round_hints
    where fk_game_round_id = in_game_round_id;

    return l_next_game_round_hint_seq_id;
  end next_game_round_hint_seq_id;


  function hint_cost(
    in_hint_type in mg_hint_types.code_id%type
  ) return mg_hint_types.hint_cost%type is
    l_hint_cost mg_hint_types.hint_cost%type;
  begin
    if in_hint_type = 'CHARACTER' then
      l_hint_cost := current_character_hint_cost;
    else
      select hint_cost
      into l_hint_cost
      from mg_hint_types
      where upper(code_id) = upper(in_hint_type);
    end if;

    return l_hint_cost;
  end hint_cost;


  procedure save_hint_to_coll(
    in_hint_type in mg_hint_types.code_id%type
  ) is
    l_hint_cost mg_hint_types.hint_cost%type;
  begin
    l_hint_cost := hint_cost(
                     in_hint_type => in_hint_type
                   );

    apex_collection.add_member(
      p_collection_name => game_round_hints_coll_name,
      p_c001 => mg_game_logic_pkg.current_game_round_number,
      p_c002 => in_hint_type,
      p_c003 => l_hint_cost
    );

    mg_game_logic_pkg.lower_game_round_score(
      in_minus_points => l_hint_cost
    );
  end save_hint_to_coll;


  /* PUBLIC */

  function game_round_hints_coll_name
  return apex_collections.collection_name%type result_cache is
  begin
    return 'GAME_ROUND_HINTS';
  end game_round_hints_coll_name;


  function current_character_hint_cost
  return mg_game_rounds_coll_vw.character_hint_cost%type is
    l_current_character_hint_cost mg_game_rounds_coll_vw.character_hint_cost%type;
  begin
    select character_hint_cost
    into l_current_character_hint_cost
    from mg_game_rounds_coll_vw
    where game_round_number = mg_game_logic_pkg.current_game_round_number;

    return l_current_character_hint_cost;
  end current_character_hint_cost;


  procedure show_hint(
    in_hint_type in mg_hint_types.code_id%type
  ) is
    l_hint apex_collections.c001%type;
  begin
    if is_valid_hint_type(in_hint_type) then
      execute immediate 'select ' || in_hint_type || '
                         from ' || mg_game_logic_pkg.game_rounds_view_name || '
                         where game_round_number = ' || mg_game_logic_pkg.current_game_round_number
      into l_hint;

      save_hint_to_coll(in_hint_type => in_hint_type);
    else
      l_hint := 'Unknown hint type';
    end if;

    apex_json.open_object;
    apex_json.write('hint', l_hint);
    apex_json.close_object;
  end show_hint;


  procedure show_actor_hint(
    in_hint_type in mg_hint_types.code_id%type
  ) is
    l_actor_number number(1);
    lr_actor_hint grt_actor_hint;
  begin
    l_actor_number := to_number(substr(in_hint_type, 6, 1));

    if is_valid_hint_type(in_hint_type) and l_actor_number between 1 and 4 then
      execute immediate 'select actor' || to_char(l_actor_number) || '_name,
                                actor' || to_char(l_actor_number) || '_photo
                         from ' || mg_game_logic_pkg.game_rounds_view_name || '
                         where game_round_number = ' || mg_game_logic_pkg.current_game_round_number
      into lr_actor_hint;

      save_hint_to_coll(in_hint_type => in_hint_type);
    else
      lr_actor_hint.actor_name := 'Unknown hint type';
      lr_actor_hint.actor_photo := 'Unknown hint type';
    end if;

    apex_json.open_object;
    apex_json.write('actorName', lr_actor_hint.actor_name);
    apex_json.write('actorPhoto', lr_actor_hint.actor_photo);
    apex_json.close_object;
  end show_actor_hint;


  procedure show_character_hint(
    in_hint_type in mg_hint_types.code_id%type
  ) is
    l_character_number number;
    l_character_hint varchar2(1);
    l_character_hint_cost mg_game_rounds_coll_vw.character_hint_cost%type;
  begin
    l_character_number := to_number(substr(in_hint_type, 5));
    l_character_hint := substr(mg_game_logic_pkg.current_game_round_movie_title, l_character_number, 1);

    save_hint_to_coll(in_hint_type => 'CHARACTER');

    apex_json.open_object;
    apex_json.write('character', l_character_hint);
    apex_json.close_object;
  end show_character_hint;


  function calculate_character_hint_cost(
    in_movie_title in mg_movies.title%type
  ) return mg_hint_types.hint_cost%type is
    lco_initial_score constant mg_game_rounds_coll_vw.score%type := 200;

    l_character_hint_cost mg_hint_types.hint_cost%type;
  begin
    l_character_hint_cost := round((lco_initial_score - 50) / length(in_movie_title));

    return l_character_hint_cost;
  end calculate_character_hint_cost;


  function hint_type_id_by_code_id(
    in_code_id in mg_hint_types.code_id%type
  ) return mg_hint_types.pk_id%type is
    l_hint_type_id mg_hint_types.pk_id%type;
  begin
    select pk_id
    into l_hint_type_id
    from mg_hint_types
    where upper(code_id) = upper(in_code_id);

    return l_hint_type_id;
  end hint_type_id_by_code_id;

end mg_hints_pkg;