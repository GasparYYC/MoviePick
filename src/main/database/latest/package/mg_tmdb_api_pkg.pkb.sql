create or replace package body mg_tmdb_api_pkg is

  gco_base_url constant varchar2(100) := 'http://api.themoviedb.org/3/movie/';
  gco_api_key constant varchar2(50) := 'da5575ff81c9503e89fee635c897cd7f';
  gco_http_method constant varchar2(30) := 'get';


  function movie_info_by_tmdb_id(
    in_tmdb_id in mg_movies.tmdb_id%type
  ) return clob is
    l_response clob;
  begin
    l_response := apex_web_service.make_rest_request(
                    p_url => gco_base_url || in_tmdb_id || '?api_key=' || gco_api_key,
                    p_http_method => gco_http_method
                  );

    return l_response;
  end movie_info_by_tmdb_id;


  function movie_credits_by_tmdb_id(
    in_tmdb_id in mg_movies.tmdb_id%type
  ) return clob is
    l_response clob;
  begin
    l_response := apex_web_service.make_rest_request(
                    p_url => gco_base_url || in_tmdb_id || '/credits?api_key=' || gco_api_key,
                    p_http_method => gco_http_method
                  );

    return l_response;
  end movie_credits_by_tmdb_id;


  procedure movie_data_to_collection(
    in_tmdb_id in mg_movies.tmdb_id%type
  ) is
    lco_movie_data_col_name constant apex_collections.collection_name%type := 'MOVIE_DATA';

    l_movie_info_response clob;
    l_movie_credits_response clob;

    l_movie_info_json apex_json.t_values;
    l_movie_credits_json apex_json.t_values;

    l_title apex_collections.c001%type;
    l_release_date date;
    l_duration apex_collections.c003%type;
    l_genres_json apex_t_varchar2;
    l_genres apex_collections.c004%type;

    l_directors_json apex_t_varchar2;
    l_directors apex_collections.c005%type;
    l_actors_json apex_t_varchar2;
    lrt_temp_actor mg_hints_pkg.grt_actor_hint;
    lrt_actor1 mg_hints_pkg.grt_actor_hint;
    lrt_actor2 mg_hints_pkg.grt_actor_hint;
    lrt_actor3 mg_hints_pkg.grt_actor_hint;
    lrt_actor4 mg_hints_pkg.grt_actor_hint;
  begin
    l_movie_info_response := movie_info_by_tmdb_id(in_tmdb_id => in_tmdb_id);
    l_movie_credits_response := movie_credits_by_tmdb_id(in_tmdb_id => in_tmdb_id);

    apex_json.parse(
      p_values => l_movie_info_json,
      p_source => l_movie_info_response
    );
    apex_json.parse(
      p_values => l_movie_credits_json,
      p_source => l_movie_credits_response
    );

    -- collect movie info data
    l_title := apex_json.get_varchar2(
                 p_path => 'title',
                 p_values => l_movie_info_json
               );
    l_release_date := apex_json.get_date(
                        p_path => 'release_date',
                        p_format => 'YYYY-MM-DD',
                        p_values => l_movie_info_json
                      );
    l_duration := apex_json.get_varchar2(
                    p_path => 'runtime',
                    p_values => l_movie_info_json
                  );
    l_genres_json := apex_json.find_paths_like(
                       p_return_path => 'genres[%]',
                       p_values => l_movie_info_json,
                       p_subpath => '.name'
                     );
    for i in 1 .. l_genres_json.count loop
      l_genres := l_genres ||
                    apex_json.get_varchar2(
                      p_path => l_genres_json(i) || '.name',
                      p_values => l_movie_info_json
                    ) || '|';
    end loop;

    -- collect movie credits data
    l_directors_json := apex_json.find_paths_like(
                          p_return_path => 'crew[%]',
                          p_subpath => '.job',
                          p_value => 'Director',
                          p_values => l_movie_credits_json
                        );

    for i in 1 .. l_directors_json.count loop
      l_directors := l_directors ||
                       apex_json.get_varchar2(
                         p_path => l_directors_json(i) || '.name',
                         p_values => l_movie_credits_json
                       ) || '|';
    end loop;

    l_actors_json := apex_json.find_paths_like(
                       p_return_path => 'cast[%]',
                       p_values => l_movie_credits_json,
                       p_subpath => '.name'
                     );

    for i in 1 .. l_actors_json.count loop
      lrt_temp_actor.actor_name := apex_json.get_varchar2(
                                     p_path => l_actors_json(i) || '.name',
                                     p_values => l_movie_credits_json
                                   );
      lrt_temp_actor.actor_photo := apex_json.get_varchar2(
                                      p_path => l_actors_json(i) || '.profile_path',
                                      p_values => l_movie_credits_json
                                    );

      if i = 1 then
        lrt_actor1 := lrt_temp_actor;
      elsif i = 2 then
        lrt_actor2 := lrt_temp_actor;
      elsif i = 3 then
        lrt_actor3 := lrt_temp_actor;
      else
        lrt_actor4 := lrt_temp_actor;
      end if;

      exit when i = 4;
    end loop;

    -- create and fill APEX collection
    apex_collection.create_or_truncate_collection(
      p_collection_name => lco_movie_data_col_name
    );

    apex_collection.add_member(
      p_collection_name => lco_movie_data_col_name,
      p_c001 => l_title,
      p_c002 => to_char(l_release_date, 'YYYY'),
      p_c003 => l_duration || ' minutes',
      p_c004 => rtrim(l_genres, '|'),
      p_c005 => rtrim(l_directors, '|'),
      p_c010 => lrt_actor1.actor_name,
      p_c011 => lrt_actor1.actor_photo,
      p_c012 => lrt_actor2.actor_name,
      p_c013 => lrt_actor2.actor_photo,
      p_c014 => lrt_actor3.actor_name,
      p_c015 => lrt_actor3.actor_photo,
      p_c016 => lrt_actor4.actor_name,
      p_c017 => lrt_actor4.actor_photo
    );
  end movie_data_to_collection;

end mg_tmdb_api_pkg;