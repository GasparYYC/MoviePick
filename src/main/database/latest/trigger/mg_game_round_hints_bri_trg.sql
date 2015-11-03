create or replace trigger mg_game_round_hints_bri_trg
before insert on mg_game_round_hints
for each row
declare
begin
  :new.pk_id := nvl(:new.pk_id, mg_game_round_hints_seq.nextval);
end mg_game_round_hints_bri_trg;