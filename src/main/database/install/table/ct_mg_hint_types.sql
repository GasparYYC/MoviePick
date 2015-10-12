create table mg_hint_types(
  pk_id number not null,
  hint_name varchar2(100) not null,
  code_id varchar2(30) not null,
  hint_cost number not null,
  seq_id number,
  active number(1),
  created_by varchar2(100) not null,
  created_on date not null,
  last_updated_by varchar2(100),
  last_updated_on date
);

alter table mg_hint_types add constraint mg_hint_types_pk primary key (pk_id);
alter table mg_hint_types add constraint mg_hint_types_code_id_un unique (code_id);