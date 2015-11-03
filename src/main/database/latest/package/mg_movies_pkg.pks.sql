create or replace package mg_movies_pkg is

  function movie_id_by_tmdb_id(
    in_tmdb_id in mg_movies.tmdb_id%type
  ) return mg_movies.pk_id%type;

  function random_tmdb_id
  return mg_movies.tmdb_id%type;

  function masked_movie_title(
    in_movie_title in mg_movies.title%type
  ) return mg_movies.title%type;

end mg_movies_pkg;