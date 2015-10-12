create or replace package body mg_movies_pkg is

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


  function validate_guess(
    in_guess in varchar2
  ) return boolean is
    l_movie_title mg_movies.title%type;
    l_is_correct_answer boolean;
  begin
    select title
    into l_movie_title
    from mg_movie_data_vw;

    l_movie_title := replace(l_movie_title, ' ', '');
    l_is_correct_answer := lower(l_movie_title) = lower(in_guess);

    return l_is_correct_answer;
  end validate_guess;

end mg_movies_pkg;