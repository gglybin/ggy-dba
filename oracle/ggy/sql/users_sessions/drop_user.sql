--#-----------------------------------------------------------------------------------
--# File Name    : drop_user.sql
--#
--# Description  : Script to drop database user with cascade option.
--# 
--# Call Syntax  : @drop_user
--#-----------------------------------------------------------------------------------

set define '%'
set linesize 200
set pages 1000
set verify off
set echo off
set feedback off
set heading off
set linesize 200
clear screen

whenever sqlerror exit sql.sqlcode rollback;

--
-- Get input values from user
--

prompt ========================== Input ==========================
prompt
accept UserToDrop  prompt "Enter user name to drop:  "

--
-- Check if user exist
--

prompt
prompt ========================== Pre-checks ======================
prompt

set serveroutput on

declare
   isExist varchar(1);
begin
   dbms_output.put_line('INFO:  Checking if %UserToDrop user exist ...');
   select count(1) into isExist from dba_users where username='%UserToDrop';
   if isExist <> 1 then
      raise_application_error(-20000,'ERROR: %UserToDrop doesn''t exist.');
   else
      dbms_output.put_line('INFO:  %UserToDrop user exist.');
   end if;
end;
/

--
-- Get confirmation from user before continue
--

prompt
prompt ========================== Confirmation =====================
prompt
prompt User %UserToDrop will be dropped.
prompt
prompt If this is correct, press ENTER to proceed.
prompt Otherwise press Ctrl+C to cancel script execution.
prompt 
prompt Note: make sure you have DBA privileges before continuing!

pause

prompt ========================== Start ============================
prompt

--
-- Backup info about user to file
--

exec dbms_output.put_line('INFO:  Backing up some info about %UserToDrop user before drop.');

undefine v_file_name
column v_file_name new_value v_file_name
set termout off
set heading on

select '%UserToDrop'||'_Backup_Info_'|| to_char(sysdate,'YYYYMMDD_HH24MISS') ||'.out' as v_file_name from dual;

spool %v_file_name
Prompt
Prompt ##
Prompt ## General:
Prompt ##

col username              for a20
col account_status        for a20
col default_tablespace    for a20
col temporary_tablespace  for a20
col "CREATED"             for a18
col password_versions     for a18

select
       username
       ,user_id
       ,account_status
       ,default_tablespace
       ,temporary_tablespace
       ,to_char(created, 'HH24:MI DD-MON-YY') as "CREATED"
       ,password_versions
from   dba_users
where  username='%UserToDrop';

Prompt
Prompt ##
Prompt ## Schema size:
Prompt ##

col owner for a15

select owner
       ,round(sum(bytes)/1024/1024,2) as "Size in MB"
from   dba_segments
where owner='%UserToDrop'
group  by owner;

Prompt
Prompt ##
Prompt ## Objects:
Prompt ##

col object_type for a45

break on report
compute sum label 'Total' of COUNT on report

select object_type
       ,count(*) "COUNT"
from   dba_objects
where  owner='%UserToDrop'
group  by object_type
order  by 2 desc;

Prompt
Prompt ##
Prompt ## User profile:
Prompt ##

col username for a20
col profile  for a40

select
      username
      ,profile
from  dba_users
where username='%UserToDrop';

Prompt
Prompt ##
Prompt ## Tablespace quotas:
Prompt ##

col tablespace_name for a50
col username        for a20

select username
       ,tablespace_name
       ,round(bytes / 1024 / 1024) MEGA_BYTES
       ,max_bytes
from  dba_ts_quotas
where username='%UserToDrop';

Prompt
Prompt ##
Prompt ## Password file entry:
Prompt ##

col username for a20
col sysdba for a8
col sysoper for a8
col sysasm for a8
col sysbackup for a10
col sysdg for a8
col syskm for a8
col account_status for a20
col lock_date for a15
col expiry_date for a15
col authentication_type for a20

select username
       ,sysdba
       ,sysoper
       ,sysasm
       ,sysbackup
       ,sysdg
       ,syskm
       ,account_status
       ,lock_date
       ,expiry_date
       ,authentication_type
from   v$pwfile_users 
where  username = upper('%UserToDrop');

Prompt
Prompt ##
Prompt ## Roles assigned to user:
Prompt ##

col grantee         for a15
col granted_role    for a40
col admin_option    for a20
col delegate_option for a20
col default_role    for a20
col common          for a20
col inherited       for a20

select *
from   dba_role_privs
where  grantee='%UserToDrop'
order  by granted_role;

Prompt
Prompt ##
Prompt ## Grants assigned directly to user:
Prompt ##

col privilege for a30

select *
from   dba_sys_privs
where  grantee='%UserToDrop'
order  by privilege;

Prompt
Prompt ##
Prompt ## Table grants assigned directly to user:
Prompt ##

col owner      for a15
col table_name for a20
col grantor    for a15
col privilege  for a20
col grantable  for a20
col hierarchy  for a20
col common     for a20
col type       for a20
col inherited  for a20

select *
from   dba_tab_privs
where  grantee='%UserToDrop'
order  by table_name desc;

Prompt
Prompt ##
Prompt ## Current count of sessions:
Prompt ##

col username for a20
col machine  for a40

break on report
compute sum label 'Total' of COUNT on report

select
       username
       ,machine
       ,status
       , count(*) as "COUNT"
from   v$session
where  username='%UserToDrop'
group  by username, machine, status
order  by 3 desc;
spool off

set heading off
set termout on

exec dbms_output.put_line('INFO:  File %v_file_name');

--
-- Avoid new sessions/logins by revoking connection grants/roles 
--

exec dbms_output.put_line('INFO:  Revoke CONNECT role from %UserToDrop user.');

declare
   v_flag varchar(1);
begin
   for c in (select 'REVOKE ' || granted_role || ' FROM '|| '%UserToDrop' as ec
             from   dba_role_privs
             where  grantee = upper('%UserToDrop'))
   loop
   begin
      execute immediate c.ec;
   exception
      when others then
      dbms_output.put_line(sqlerrm);
      raise_application_error(-20000,'ERROR: Failed to revoke roles to %UserToDrop user.');
   end;
   end loop;
   select count(1) into v_flag from dba_sys_privs where grantee = upper('%UserToDrop') and privilege = 'CREATE SESSION';
   if v_flag = 1 then
      execute immediate 'REVOKE CREATE SESSION FROM %UserToDrop';
   end if;
end;
/

--
-- Kill current sessions
--

exec dbms_output.put_line('INFO:  Killing current %UserToDrop sessions.');

begin
   for c in (select 'ALTER SYSTEM KILL SESSION ' || '''' || sid || ',' || serial# || ''' immediate' as ec
             from   v$session 
             where  username = upper('%UserToDrop'))
   loop
   begin
      execute immediate c.ec;
   exception
      when others then
      dbms_output.put_line(sqlerrm);
      raise_application_error(-20000,'ERROR: Failed to kill %UserToDrop user sessions.');
   end;
   end loop;
end;
/

--
-- Drop with cascade oprion
--

exec dbms_output.put_line('INFO:  Droping %UserToDrop with cascade option.');
drop user %UserToDrop cascade;
exec dbms_output.put_line('INFO:  Completed!');

prompt
prompt ========================== Done =============================
prompt
exit;
