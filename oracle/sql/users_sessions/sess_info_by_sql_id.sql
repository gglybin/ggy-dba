--#-----------------------------------------------------------------------------------
--# File Name    : sess_info_by_sql_id.sql
--#
--# Description  : Shows current sessions running specific SQL_ID.
--#
--# Call Syntax  : SQL> @sess_info_by_sql_id (sql-id)
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

Prompt
Prompt ##
Prompt ## All sessions with SQL_ID = &&1:
Prompt ##

col "LOGON_TIME" for a22
col username     for a20
col schemaname   for a20
col osuser       for a15
col status       for a10
col "SID,SERIAL" for a15
col "OS_PROCESS" for a10
col machine      for a50
col program      for a30

select to_char(s.logon_time, 'DD-MON-YY HH24:MI') "LOGON_TIME"
       ,s.sql_id
       ,s.username
       ,s.schemaname
       ,s.osuser
       ,s.status
       ,s.sid||','||s.serial# as "SID,SERIAL"
       ,p.spid as "OS_PROCESS"
       ,s.machine
from   v$session s,
       v$process p
where  s.paddr=p.addr
and    type<>'BACKGROUND'
and    s.sql_id='&&1'
order  by s.logon_time;
