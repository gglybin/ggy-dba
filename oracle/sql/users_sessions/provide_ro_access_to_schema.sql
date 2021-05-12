--#-----------------------------------------------------------------------------------
--# File Name    : provide_ro_access_to_schema.sql
--#
--# Description  : Script to provide READ-ONLY access on (source-schema) user objects (tables, views, mviews) to another user (target-user).
--#
--# Call Syntax  : @provide_ro_access_to_schema (source-schema) (target-schema)
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;
set serveroutput on;

whenever sqlerror exit sql.sqlcode rollback;

Prompt
Prompt ##
Prompt ## Pre-Checks:
Prompt ##

set feedback off;

declare
   isExist varchar(1);
begin
   dbms_output.put_line(chr(1));
   dbms_output.put_line('INFO:  Checking if &&1 user exist ...');
   select count(1) into isExist from dba_users where username='&&1';
   if isExist <> 1 then
     raise_application_error(-20000,'ERROR: User with name &&1 doesn''t exist.');
   else
     dbms_output.put_line(chr(1));
     dbms_output.put_line('INFO:  &&1 user exist.');
  end if;
  dbms_output.put_line(chr(1));
  dbms_output.put_line('INFO:  Checking if &&2 user exist ...');
  select count(1) into isExist from dba_users where username='&&2';
  if isExist <> 1 then
    raise_application_error(-20000,'ERROR: User with name &&2 doesn''t exist.');
  else
    dbms_output.put_line(chr(1));
    dbms_output.put_line('INFO:  &&2 user exist.');
 end if;
end;
/

Prompt
Prompt ##
Prompt ## Tables access:
Prompt ##

begin
  for rec in (select 'grant select on &&1'||'.'|| object_name || ' to &&2' as cmd from dba_objects where owner='&&1' and object_type='TABLE')
  loop
    --dbms_output.put_line(chr(1));
    --dbms_output.put_line(rec.cmd);
    execute immediate rec.cmd;
  end loop;
  dbms_output.put_line(chr(1));
  dbms_output.put_line('INFO:  Access to all &&1 user tables has been provided to &&2 user.');
end;
/

Prompt
Prompt ##
Prompt ## Views access:
Prompt ##

begin
  for rec in (select 'grant select on &&1'||'.'|| object_name || ' to &&2' as cmd from dba_objects where owner='&&1' and object_type='VIEW')
  loop
    --dbms_output.put_line(chr(1));
    --dbms_output.put_line(rec.cmd);
    execute immediate rec.cmd;
  end loop;
  dbms_output.put_line(chr(1));
  dbms_output.put_line('INFO:  Access to all &&1 user views has been provided to &&2 user.');
end;
/

Prompt
Prompt ##
Prompt ## Materialized Views access:
Prompt ##

begin
  for rec in (select 'grant select on &&1'||'.'|| object_name || ' to &&2' as cmd from dba_objects where owner='&&1' and object_type='MATERIALIZED VIEW')
  loop
    --dbms_output.put_line(chr(1));
    --dbms_output.put_line(rec.cmd);
    execute immediate rec.cmd;
  end loop;
  dbms_output.put_line(chr(1));
  dbms_output.put_line('INFO:  Access to all &&1 user m-views has been provided to &&2 user.');
end;
/

Prompt
exec dbms_output.put_line('Completed!');
Prompt
Prompt Note: use "user_info.sql" script to get more detailed information about the user and its grants.
Prompt
