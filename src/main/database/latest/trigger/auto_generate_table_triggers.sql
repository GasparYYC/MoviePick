declare
  type laat_table_names
    is table of user_tables.table_name%type
    index by pls_integer;

  laa_table_names laat_table_names;
  l_index number;
  l_trigger_name user_triggers.trigger_name%type;
begin
  laa_table_names(1)  := 'mg_movies';
  laa_table_names(2)  := 'mg_hint_types';
  laa_table_names(3)  := 'mg_players';
  laa_table_names(4)  := 'mg_games';
  laa_table_names(5)  := 'mg_game_rounds';
  laa_table_names(6)  := 'mg_guesses';

  l_index := laa_table_names.first;
  while l_index is not null loop
    l_trigger_name := substr(laa_table_names(l_index), 1, 21) || '_briu_trg';

    execute immediate '
create or replace trigger ' || l_trigger_name || '
before insert or update on ' || laa_table_names(l_index) || '
for each row
declare
  l_user varchar2(100) := nvl(v(''APP_USER''), user);
begin
  :new.pk_id := nvl(:new.pk_id, ' || laa_table_names(l_index) || '_seq.nextval);

  if inserting then
    :new.created_by := nvl(:new.created_by, l_user);
    :new.created_on := nvl(:new.created_on, sysdate);
  end if;

  if updating then
    :new.last_updated_by := l_user;
    :new.last_updated_on := sysdate;
  end if;
end ' || l_trigger_name || ';
';
    l_index := laa_table_names.next(l_index);
  end loop;
end;