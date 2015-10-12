create table mg_movies(
  pk_id number not null,
  tmdb_id varchar2(50) not null,
  title varchar2(255) not null,
  active number(1),
  created_by varchar2(100) not null,
  created_on date not null,
  last_updated_by varchar2(100),
  last_updated_on date
);

alter table mg_movies add constraint mg_movies_pk primary key (pk_id);
alter table mg_movies add constraint mg_movies_tmdb_id_un unique (tmdb_id);