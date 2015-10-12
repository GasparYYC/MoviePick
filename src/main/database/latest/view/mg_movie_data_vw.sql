create or replace force view mg_movie_data_vw as
  select c001 as title,
         c002 as year,
         c003 as duration,
         c004 as genres,
         c005 as directors,
         c010 as actor1_name,
         c011 as actor1_photo,
         c012 as actor2_name,
         c013 as actor2_photo,
         c014 as actor3_name,
         c015 as actor3_photo,
         c016 as actor4_name,
         c017 as actor4_photo
  from apex_collections
  where collection_name = 'MOVIE_DATA';