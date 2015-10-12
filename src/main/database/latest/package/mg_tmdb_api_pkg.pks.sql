create or replace package mg_tmdb_api_pkg is

  function movie_info_by_tmdb_id(
    in_tmdb_id in mg_movies.tmdb_id%type
  ) return clob;

  function movie_credits_by_tmdb_id(
    in_tmdb_id in mg_movies.tmdb_id%type
  ) return clob;

  procedure movie_data_to_collection(
    in_tmdb_id in mg_movies.tmdb_id%type
  );

end mg_tmdb_api_pkg;