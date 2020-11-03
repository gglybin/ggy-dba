--#-----------------------------------------------------------------------------------
--# File Name    : sess_info_by_user.sql
--#
--# Description  : Shows all user sessions currently connected to database.
--#
--# Call Syntax  : @sess_info_by_user (user-name)
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

Prompt
Prompt ##
Prompt ## All &&1 user sessions:
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
and    s.username='&&1'
order  by s.logon_time;

Prompt
Prompt Note: use "sess_info.sql" script to get more detailed information about the particular session.
Prompt
