create or replace force view mg_game_round_guesses_coll_vw as
  select seq_id as seq_id,
         c001 as game_round_number,
         c002 as guess,
         c003 as correct
  from apex_collections
  where collection_name = 'GAME_ROUND_GUESSES';