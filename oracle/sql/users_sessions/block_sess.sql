--#-----------------------------------------------------------------------------------
--# File Name    : block_sess.sql
--#
--# Description  : Shows information about blocking/waiting sessions in database.
--#
--# Call Syntax  : @block_sess
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';

Prompt
Prompt ##
Prompt ## Blockers:
Prompt ##

col logon_time   for a20
col username     for a20
col schemaname   for a20
col status       for a10
col "SID,SERIAL" for a15
col "OSPROCESS"  for a10
col osuser       for a15
col machine      for a20
col program      for a30
col event        for a40
col sql_id       for a15
col prev_sql_id  for a15


select
       s.logon_time
       ,s.username
       ,s.status
       ,s.sid||','||s.serial# as "SID,SERIAL"
       ,p.spid as "OSPROCESS"
       ,s.sql_id
       ,s.prev_sql_id
       ,s.event
       ,s.osuser
       ,s.machine
       ,s.program
from   v$session s,
       v$process p
where  s.paddr=p.addr
and    sid in (select final_blocking_session from v$session where final_blocking_session_status='VALID')
order  by s.logon_time desc;

Prompt ##
Prompt ## Waiting sessions:
Prompt ##

select
       s.logon_time
       ,s.username
       ,s.status
       ,s.sid||','||s.serial# as "SID,SERIAL"
       ,p.spid as "OSPROCESS"
       ,s.sql_id
       ,s.prev_sql_id
       ,s.event
       ,s.osuser
       ,s.machine
       ,s.program
from   v$session s,
       v$process p
where  s.paddr=p.addr
and    sid in (select sid from v$session where final_blocking_session_status='VALID')
order  by s.logon_time desc;

Prompt ##
Prompt ## Stats:
Prompt ##

select
       --s.sid||','||s.serial# as "Blocker SID/SERIAL"
       final_blocking_session as "Blocker SID"
       ,count(*) as "Count of Waiting sessions"
from   v$session s,
       v$process p
where  s.paddr=p.addr
and final_blocking_session_status='VALID'
group by final_blocking_session
order by 2 desc;

Prompt
Prompt Note: use "sess_info.sql" script to get more detailed information about the particular session.
Prompt
