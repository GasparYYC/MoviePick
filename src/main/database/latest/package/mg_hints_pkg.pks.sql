create or replace package mg_hints_pkg is

  type grt_actor_hint is record(
    actor_name varchar2(255),
    actor_photo varchar2(400)
  );

  function is_valid_hint_type(
    in_hint_type in mg_hint_types.code_id%type
  ) return boolean;

  function show_hint(
    in_hint_type in mg_hint_types.code_id%type
  ) return apex_collections.c001%type;

  function show_actor_hint(
    in_hint_type in mg_hint_types.code_id%type
  ) return grt_actor_hint;

  function show_character_hint(
    in_hint_type in mg_hint_types.code_id%type
  ) return varchar2;

end mg_hints_pkg;