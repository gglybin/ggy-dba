set lines 400 pages 1000
set verify off;

Prompt
Prompt ##
Prompt ## General:
Prompt ##

col username              for a20
col account_status        for a20
col default_tablespace    for a20
col temporary_tablespace  for a20
col local_temp_tablespace for a22
col "CREATED"             for a18
col password_versions     for a18
col "LAST_PWD_CHANGE"     for a18
col "LAST_LOGIN"          for a18

select
       username
       ,user_id
       ,account_status
       ,default_tablespace
       ,temporary_tablespace
       ,local_temp_tablespace
       ,to_char(created, 'HH24:MI DD-MON-YY') as "CREATED"
       ,password_versions
       ,to_char(password_change_date, 'HH24:MI DD-MON-YY') as "LAST_PWD_CHANGE"
       ,to_char(last_login, 'HH24:MI DD-MON-YY') as "LAST_LOGIN"
from   dba_users
where  username='&&1';

Prompt ##
Prompt ## Schema size:
Prompt ##

col owner for a15

select owner
       ,round(sum(bytes)/1024/1024,2) as "Size in MB"
from   dba_segments
where owner='&&1'
group  by owner;

Prompt ##
Prompt ## Objects:
Prompt ##

col object_type for a45

break on report
compute sum label 'Total' of COUNT on report

select object_type
       ,count(*) "COUNT"
from   dba_objects
where  owner='&&1'
group  by object_type
order  by 2 desc;

Prompt ##
Prompt ## Invalid Objects:
Prompt ##

col object_type for a45

break on report
compute sum label 'Total' of COUNT on report

select object_type
       ,count(*) "COUNT"
from   dba_objects
where  owner='&&1'
and    status<>'VALID'
group  by object_type
order  by 2 desc;

Prompt ##
Prompt ## Top 10 schema objects:
Prompt ##

col segment_name    for a60
col segment_type    for a30
col partition_name  for a30
col tablespace_name for a20

select *
from   (select owner
               ,tablespace_name
               ,segment_type
               ,segment_name
               ,partition_name
               ,round(bytes/(1024*1024),2) SIZE_MB
        from   dba_segments
        where  owner='&&1'
        and    segment_type in ('TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION','INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION', 'TEMPORARY', 'LOBINDEX', 'LOBSEGMENT', 'LOB PARTITION')
        order by bytes desc)
where rownum <=10;

Prompt ##
Prompt ## User profile:
Prompt ##

col username for a20
col profile  for a40

select 
      username
      ,profile 
from  dba_users 
where username='&&1';

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
where username='&&1'; 

Prompt ##
Prompt ## Password file entry:
Prompt ##

col username            for a20
col sysdba              for a8
col sysoper             for a8
col sysasm              for a8
col sysbackup           for a10
col sysdg               for a8
col syskm               for a8
col account_status      for a20
col lock_date           for a15
col expiry_date         for a15
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
where  grantee='&&1'
order  by granted_role;

Prompt ##
Prompt ## Grants assigned directly to user:
Prompt ##

col privilege for a30

select *
from   dba_sys_privs
where  grantee='&&1'
order  by privilege;

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
where  grantee='&&1'
order  by table_name desc;

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
where  username='&&1'
group  by username, machine, status
order  by 3 desc;

/*
Prompt ##
Prompt ## Session details:
Prompt ##

alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';

col logon_time  for a20
col username    for a20
col schemaname  for a20
col status      for a10
col "OSPROCESS" for a10
col osuser      for a15
col machine     for a20
col program     for a30
col module      for a20
col event       for a50

select
       s.logon_time
       ,s.username
       ,s.schemaname
       ,s.status
       ,s.sid
       ,s.serial#
       ,p.spid as "OSPROCESS"
       ,s.osuser
       ,s.machine
       ,s.program
       ,s.module
       ,s.event
from   v$session s
       ,v$process p
where  s.username='&&1'
and    s.paddr=p.addr
order  by logon_time desc, status desc;
*/

Prompt
Prompt Note: use "sess_info_by_user.sql" script to get info about user sessions.
Prompt
