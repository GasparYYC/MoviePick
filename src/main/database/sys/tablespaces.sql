create tablespace dev_movie_game
  datafile '/u01/app/oracle/db/oradata/orcl/pdbapex5/dev_movie_game01.dbf'
  size 256m
  autoextend on
  next 10m maxsize 1024m;

drop tablespace dev_movie_game
  including contents and datafiles
  cascade constraints;



create tablespace tst_movie_game
  datafile '/u01/app/oracle/db/oradata/orcl/pdbapex5/tst_movie_game01.dbf'
  size 256m
  autoextend on
  next 10m maxsize 1024m;

drop tablespace tst_movie_game
  including contents and datafiles
  cascade constraints;



create tablespace prd_movie_game
  datafile '/u01/app/oracle/db/oradata/orcl/pdbapex5/prd_movie_game01.dbf'
  size 512m
  autoextend on
  next 10m maxsize 2048m;

drop tablespace prd_movie_game
  including contents and datafiles
  cascade constraints;