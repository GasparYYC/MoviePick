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


  function movie_images_by_tmdb_id(
    in_tmdb_id in mg_movies.tmdb_id%type
  ) return clob is
    l_response clob;
  begin
    l_response := apex_web_service.make_rest_request(
                    p_url => gco_base_url || in_tmdb_id || '/images?api_key=' || gco_api_key,
                    p_http_method => gco_http_method
                  );

    return l_response;
  end movie_images_by_tmdb_id;


  procedure movie_data_to_collection(
    in_tmdb_id in mg_movies.tmdb_id%type
  ) is
    lco_multi_value_separator constant varchar2(1) := '|';
    lco_tmdb_actor_img_url constant apex_collections.c011%type := 'https://image.tmdb.org/t/p/w90';
    lco_tmdb_backdrop_img_url constant apex_collections.c020%type := 'https://image.tmdb.org/t/p/w300';
    lco_tmdb_poster_img_url constant apex_collections.c025%type := 'https://image.tmdb.org/t/p/w342';

    l_movie_info_response clob;
    l_movie_credits_response clob;
    l_movie_images_response clob;

    l_movie_info_json apex_json.t_values;
    l_movie_credits_json apex_json.t_values;
    l_movie_images_json apex_json.t_values;

    -- movie facts
    l_title apex_collections.c001%type;
    l_release_date date;
    l_duration apex_collections.c003%type;
    l_genres_json apex_t_varchar2;
    l_genres apex_collections.c004%type;
    l_directors_json apex_t_varchar2;
    l_directors apex_collections.c005%type;

    -- actors
    l_actors_json apex_t_varchar2;
    lr_temp_actor mg_hints_pkg.grt_actor_hint;
    lr_actor1 mg_hints_pkg.grt_actor_hint;
    lr_actor2 mg_hints_pkg.grt_actor_hint;
    lr_actor3 mg_hints_pkg.grt_actor_hint;
    lr_actor4 mg_hints_pkg.grt_actor_hint;

    -- backdrops
    l_backdrops_json apex_t_varchar2;
    l_backdrop1 apex_collections.c020%type;
    l_backdrop2 apex_collections.c021%type;

    -- poster
    l_posters_json apex_t_varchar2;
    l_poster apex_collections.c025%type;
  begin
    l_movie_info_response := movie_info_by_tmdb_id(in_tmdb_id => in_tmdb_id);
    l_movie_credits_response := movie_credits_by_tmdb_id(in_tmdb_id => in_tmdb_id);
    l_movie_images_response := movie_images_by_tmdb_id(in_tmdb_id => in_tmdb_id);

    apex_json.parse(
      p_values => l_movie_info_json,
      p_source => l_movie_info_response
    );
    apex_json.parse(
      p_values => l_movie_credits_json,
      p_source => l_movie_credits_response
    );
    apex_json.parse(
      p_values => l_movie_images_json,
      p_source => l_movie_images_response
    );

    -- gather movie facts
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
                       p_subpath => '.name',
                       p_values => l_movie_info_json
                     );
    for i in 1 .. l_genres_json.count loop
      l_genres := l_genres ||
                    apex_json.get_varchar2(
                      p_path => l_genres_json(i) || '.name',
                      p_values => l_movie_info_json
                    ) || lco_multi_value_separator;
    end loop;

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
                       ) || lco_multi_value_separator;
    end loop;

    -- gather actors
    l_actors_json := apex_json.find_paths_like(
                       p_return_path => 'cast[%]',
                       p_subpath => '.name',
                       p_values => l_movie_credits_json
                     );
    for i in 1 .. l_actors_json.count loop
      lr_temp_actor.actor_name := apex_json.get_varchar2(
                                     p_path => l_actors_json(i) || '.name',
                                     p_values => l_movie_credits_json
                                   );
      lr_temp_actor.actor_photo := lco_tmdb_actor_img_url ||
                                   apex_json.get_varchar2(
                                     p_path => l_actors_json(i) || '.profile_path',
                                     p_values => l_movie_credits_json
                                   );

      case i
        when 1 then lr_actor1 := lr_temp_actor;
        when 2 then lr_actor2 := lr_temp_actor;
        when 3 then lr_actor3 := lr_temp_actor;
        when 4 then lr_actor4 := lr_temp_actor;
        else null;
      end case;

      exit when i = 4;
    end loop;

    -- gather backdrops
    l_backdrops_json := apex_json.find_paths_like(
                          p_return_path => 'backdrops[%]',
                          p_subpath => '.file_path',
                          p_values => l_movie_images_json
                        );
    l_backdrop1 := lco_tmdb_backdrop_img_url ||
                   apex_json.get_varchar2(
                     p_path => l_backdrops_json(2) || '.file_path',
                     p_values => l_movie_images_json
                   );
    l_backdrop2 := lco_tmdb_backdrop_img_url ||
                   apex_json.get_varchar2(
                     p_path => l_backdrops_json(3) || '.file_path',
                     p_values => l_movie_images_json
                   );

    -- gather poster
    l_posters_json := apex_json.find_paths_like(
                        p_return_path => 'posters[%]',
                        p_subpath => '.file_path',
                        p_values => l_movie_images_json
                      );
    l_poster := lco_tmdb_poster_img_url ||
                apex_json.get_varchar2(
                  p_path => l_posters_json(1) || '.file_path',
                  p_values => l_movie_images_json
                );

    -- add movie data to collection
    apex_collection.add_member(
      p_collection_name => mg_game_logic_pkg.game_rounds_coll_name,
      p_c001 => l_title,
      p_c002 => to_char(l_release_date, 'YYYY'),
      p_c003 => l_duration || ' minutes',
      p_c004 => rtrim(l_genres, lco_multi_value_separator),
      p_c005 => rtrim(l_directors, lco_multi_value_separator),
      p_c010 => lr_actor1.actor_name,
      p_c011 => lr_actor1.actor_photo,
      p_c012 => lr_actor2.actor_name,
      p_c013 => lr_actor2.actor_photo,
      p_c014 => lr_actor3.actor_name,
      p_c015 => lr_actor3.actor_photo,
      p_c016 => lr_actor4.actor_name,
      p_c017 => lr_actor4.actor_photo,
      p_c020 => l_backdrop1,
      p_c021 => l_backdrop2,
      p_c025 => l_poster,
      p_c050 => in_tmdb_id
    );
  end movie_data_to_collection;

end mg_tmdb_api_pkg;