begin
  dbms_network_acl_admin.create_acl(
    acl         => 'tmdb_ws.xml',
    description => 'the movie database web service API',
    principal   => 'APEX_050000',
    is_grant    => true,
    privilege   => 'connect'
  );

  commit;
end;
/

begin
  dbms_network_acl_admin.add_privilege(
    acl       => 'tmdb_ws.xml',
    principal => 'APEX_050000',
    is_grant  => true,
    privilege => 'resolve'
  );

  commit;
end;
/

begin
  dbms_network_acl_admin.assign_acl(
    acl  => 'tmdb_ws.xml',
    host => 'api.themoviedb.org',
    lower_port => 80,
    upper_port => 443
  );

  commit;
end;
/

begin
  dbms_network_acl_admin.drop_acl(
    'tmdb_ws.xml'
  );

  commit;
end;
/