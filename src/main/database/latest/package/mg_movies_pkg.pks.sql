create or replace package mg_movies_pkg is

  function random_tmdb_id
  return mg_movies.tmdb_id%type;

  function masked_movie_title(
    in_movie_title in mg_movies.title%type
  ) return mg_movies.title%type;

  function validate_guess(
    in_guess in varchar2
  ) return boolean;

end mg_movies_pkg;