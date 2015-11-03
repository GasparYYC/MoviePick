create or replace force view mg_game_round_hints_coll_vw as
  select seq_id as seq_id,
         c001 as game_round_number,
         c002 as hint_type,
         c003 as hint_cost
  from apex_collections
  where collection_name = 'GAME_ROUND_HINTS';