--#-----------------------------------------------------------------------------------
--# File Name    : create_clone_user.sql
--#
--# Description  : Script to create "clone" user, i.e. with same grants to objects in database. It not creates objects.
--#
--# Call Syntax  : @create_clone_user
--#-----------------------------------------------------------------------------------

set define '%'
set lines 1000 pages 1000
set verify off
set echo off
set feedback off
set heading off
set linesize 160
clear screen

whenever sqlerror exit sql.sqlcode rollback;

--
-- Get input values from user
--

prompt ========================== Input ==========================
prompt
accept SourceUser  prompt "Enter source user name [%_USER]: " default %_USER
accept NewUser     prompt "Enter new user name [SCOTT]: "      default SCOTT
accept NewPassword prompt "Enter password for new user [leave blank to copy]: " hide

--
-- Check if SourceUser exist and NewUser doesn't exist
--

prompt
prompt ========================== Pre-checks ======================
prompt

set serveroutput on

declare
   isExist varchar(1);
begin
   dbms_output.put_line('INFO:  Checking if %SourceUser user exist ...');
   select count(1) into isExist from dba_users where username='%SourceUser';
   if isExist <> 1 then
      raise_application_error(-20000,'ERROR: Source user %SourceUser doesn''t exist.');
   else
      dbms_output.put_line('INFO:  %SourceUser user exist.');
   end if;
   dbms_output.put_line('INFO:  Checking if %NewUser user doesn''t exist ...');
   select count(1) into isExist from dba_users where username='%NewUser';
   if isExist = 1 then
      raise_application_error(-20000,'ERROR: New user %NewUser already exist.');
   else
      dbms_output.put_line('INFO:  %NewUser user  doesn''t exist.');
  end if;
end;
/

--
-- Get confirmation from user before continue
--

prompt
prompt ========================== Confirmation =====================
prompt
prompt Source user   = %SourceUser
prompt New user      = %NewUser
prompt
prompt If this is correct, press ENTER to proceed.
prompt Otherwise press Ctrl+C to cancel script execution.
prompt 
prompt Note: make sure you have DBA privileges before continuing!

pause

prompt ========================== Start ============================
prompt

--
-- Create new user
--

declare
   v_query varchar(1000);
   v_source_pwd varchar(1000);
begin
   select spare4||';'||password into v_source_pwd from sys.user$ where name='%SourceUser';
   select 'CREATE USER %NewUser ' ||
          case when password = 'EXTERNAL' then 'IDENTIFIED EXTERNALLY'
               when password = 'GLOBAL'   then 'IDENTIFIED GLOBALLY AS ''' ||
                 replace (external_name,'%SourceUser','%NewUser') || ''''
               else 'IDENTIFIED BY ' ||
                 decode('%NewPassword',null,'VALUES ''' || v_source_pwd  || '''','"%NewPassword"')
          end
          || ' DEFAULT TABLESPACE ' || default_tablespace ||
          ' TEMPORARY TABLESPACE ' || temporary_tablespace ||
          ' PROFILE ' || profile || ' ACCOUNT ' ||
          decode(account_status,'OPEN','UNLOCK',
                                'EXPIRED','UNLOCK PASSWORD EXPIRE',
                                'EXPIRED(GRACE)','UNLOCK',
                                'LOCKED(TIMED)','UNLOCK',
                                'LOCKED','LOCK',
                                'EXPIRED & LOCKED(TIMED)','UNLOCK PASSWORD EXPIRE',
                                'EXPIRED(GRACE) & LOCKED(TIMED)','UNLOCK',
                                'EXPIRED & LOCKED','LOCK PASSWORD EXPIRE',
                                'EXPIRED(GRACE) & LOCKED','LOCK',
                                'LOCK') into v_query
   from dba_users
   where username = upper('%SourceUser');
   execute immediate v_query;
   dbms_output.put_line('INFO:  Created %NewUser user.'); 
exception
   when others then
      dbms_output.put_line(sqlerrm);
      raise_application_error(-20000,'ERROR: User creation failed.');  
end;
/ 

--
-- Assign tablespace quotas
--

begin   
   for c in (select 'ALTER USER %NewUser QUOTA ' || decode(max_bytes,-1,'UNLIMITED',max_bytes) || ' ON ' || tablespace_name as ec
             from   dba_ts_quotas
             where  username = upper('%SourceUser')) 
   loop
   begin
      execute immediate c.ec;
   exception
      when others then
      dbms_output.put_line(sqlerrm);
      raise_application_error(-20000,'ERROR: Failed to assign tablespace quotas to new user.');
   end;
   end loop;
   dbms_output.put_line('INFO:  Assigned tablespace quotas for %NewUser user.');
end;
/

--
-- Check/assign SYSDBA/SYSOPER privileges
--

declare
   isSYSDBA  varchar(1);
   isSYSOPER varchar(1);
   v_query   varchar(1000);
begin
   select count(1) into isSYSDBA from v$pwfile_users where username = upper('%SourceUser') and sysdba='TRUE';
   if isSYSDBA = 1 then
      execute immediate 'GRANT SYSDBA TO %NewUser';
      dbms_output.put_line('INFO:  Assigned SYSDBA grant to %NewUser user.');
   end if;
   select count(1) into isSYSOPER from v$pwfile_users where username = upper('%SourceUser') and sysoper='TRUE';
   if isSYSOPER = 1 then
      execute immediate 'GRANT SYSOPER TO %NewUser';
      dbms_output.put_line('INFO:  Assigned SYSOPER grant to %NewUser user.');
   end if;
end;
/

--
-- Assigning roles
--

begin
   for c in (select 'GRANT ' || granted_role || ' TO %NewUser' || decode(admin_option,'YES',' WITH ADMIN OPTION') as ec
             from   dba_role_privs
             where  grantee = upper('%SourceUser'))
   loop
   begin
      execute immediate c.ec;
   exception
      when others then
      dbms_output.put_line(sqlerrm);
      raise_application_error(-20000,'ERROR: Failed to assign roles to %NewUser user.');
   end;
   end loop;
   dbms_output.put_line('INFO:  Assigned roles to %NewUser user.');
end;
/

--
-- Set default roles
--

declare
  v_default_roles varchar2(4000) := null;
begin
  for c1 in (select * from sys.dba_role_privs
             where  grantee = upper('%SourceUser')
             and    default_role = 'YES')
  loop
    if length(v_default_roles) > 0 then
      v_default_roles := v_default_roles || ',' || c1.granted_role;
    else
      v_default_roles := v_default_roles || c1.granted_role;
    end if;
  end loop;
  if length(v_default_roles) > 0 then
    execute immediate 'ALTER USER %NewUser DEFAULT ROLE '|| v_default_roles;
    dbms_output.put_line('INFO:  Set default roles to %NewUser user.');
  end if;
end;
/

--
-- Assign system grants
--

begin
   for c in (select 'GRANT ' || privilege || ' TO %NewUser' || decode(admin_option,'YES',' WITH ADMIN OPTION;') as ec
             from   dba_sys_privs
             where  grantee = upper('%SourceUser'))
   loop
   begin
      execute immediate c.ec;
   exception
      when others then
      dbms_output.put_line(sqlerrm);
      raise_application_error(-20000,'ERROR: Failed to assign system grants to %NewUser user.');
   end;
   end loop;
   dbms_output.put_line('INFO:  Assigned system grants to %NewUser user.');
end;
/

--
-- Assign object grants
--

begin
   for c in (select 'GRANT ' || privilege || ' ON ' || owner || '.' || table_name || ' TO %NewUser' as ec
             from   dba_tab_privs
             where  grantee = upper('%SourceUser'))
   loop
   begin
      execute immediate c.ec;
   exception
      when others then
      dbms_output.put_line(sqlerrm);
      raise_application_error(-20000,'ERROR: Failed to assign object grants to %NewUser user.');
   end;
   end loop;
   dbms_output.put_line('INFO:  Assigned object grants to %NewUser user.');
end;
/

set serveroutput off

prompt
prompt ========================== Done =============================
prompt
exit;
