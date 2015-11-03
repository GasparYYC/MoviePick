create or replace package body mg_movies_pkg is

  function movie_id_by_tmdb_id(
    in_tmdb_id in mg_movies.tmdb_id%type
  ) return mg_movies.pk_id%type is
    l_movie_pk_id mg_movies.pk_id%type;
  begin
    select pk_id
    into l_movie_pk_id
    from mg_movies
    where tmdb_id = in_tmdb_id;

    return l_movie_pk_id;
  end movie_id_by_tmdb_id;


  function random_tmdb_id
  return mg_movies.tmdb_id%type is
    l_random_tmdb_id mg_movies.tmdb_id%type;
  begin
    select tmdb_id
    into l_random_tmdb_id
    from(
      select tmdb_id
      from mg_movies
      where active = 1
      and tmdb_id not in (select tmdb_id from mg_game_rounds_coll_vw)
      order by dbms_random.value)
    where rownum = 1;

    return l_random_tmdb_id;
  end random_tmdb_id;


  function masked_movie_title(
    in_movie_title in mg_movies.title%type
  ) return mg_movies.title%type is
    l_masked_movie_title mg_movies.title%type;
  begin
    for i in 1 .. length(in_movie_title) loop
      if substr(in_movie_title, i, 1) = ' ' then
        l_masked_movie_title := l_masked_movie_title || '_';
      else
        l_masked_movie_title := l_masked_movie_title || 'X';
      end if;
    end loop;

    return l_masked_movie_title;
  end masked_movie_title;

end mg_movies_pkg;