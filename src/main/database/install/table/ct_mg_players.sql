create table mg_players(
  pk_id number not null,
  first_name varchar2(100),
  last_name varchar2(100),
  created_by varchar2(100) not null,
  created_on date not null,
  last_updated_by varchar2(100),
  last_updated_on date
);

alter table mg_players add constraint mg_players_pk primary key (pk_id);