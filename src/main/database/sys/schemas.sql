create user dev_movie_game
identified by secret
default tablespace dev_movie_game
quota unlimited on dev_movie_game
temporary tablespace temp;

grant create session,
      create table,
      create view,
      create procedure,
      create trigger,
      create type,
      create sequence,
      create synonym,
      create job
to dev_movie_game;



create user tst_movie_game
identified by secret
default tablespace tst_movie_game
quota unlimited on tst_movie_game
temporary tablespace temp;

grant create session,
      create table,
      create view,
      create procedure,
      create trigger,
      create type,
      create sequence,
      create synonym,
      create job
to tst_movie_game;



create user prd_movie_game
identified by secret
default tablespace prd_movie_game
quota unlimited on prd_movie_game
temporary tablespace temp;

grant create session,
      create table,
      create view,
      create procedure,
      create trigger,
      create type,
      create sequence,
      create synonym,
      create job
to prd_movie_game;