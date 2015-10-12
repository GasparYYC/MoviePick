create or replace package body mg_hints_pkg is

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


  function show_hint(
    in_hint_type in mg_hint_types.code_id%type
  ) return apex_collections.c001%type is
    l_hint apex_collections.c001%type;
  begin
    if is_valid_hint_type(in_hint_type) then
      execute immediate 'select ' || in_hint_type || '
                         from mg_movie_data_vw'
      into l_hint;
    else
      l_hint := 'Unknown hint type';
    end if;

    return l_hint;
  end show_hint;


  function show_actor_hint(
    in_hint_type in mg_hint_types.code_id%type
  ) return grt_actor_hint is
    l_actor_number number(1);
    lrt_actor_hint grt_actor_hint;
  begin
    l_actor_number := to_number(substr(in_hint_type, 6, 1));

    if is_valid_hint_type(in_hint_type) and l_actor_number between 1 and 4 then
      execute immediate 'select actor' || to_char(l_actor_number) || '_name,
                                actor' || to_char(l_actor_number) || '_photo
                         from mg_movie_data_vw'
      into lrt_actor_hint;
    else
      lrt_actor_hint.actor_name := 'Unknown hint type';
      lrt_actor_hint.actor_photo := 'Unknown hint type';
    end if;

    return lrt_actor_hint;
  end show_actor_hint;


  function show_character_hint(
    in_hint_type in mg_hint_types.code_id%type
  ) return varchar2 is
    l_character_number number;
    l_character_hint varchar2(1);
  begin
    l_character_number := to_number(substr(in_hint_type, 5));

    select substr(title, l_character_number, 1)
    into l_character_hint
    from mg_movie_data_vw;

    return l_character_hint;
  end show_character_hint;

end mg_hints_pkg;