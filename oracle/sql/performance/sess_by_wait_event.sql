--#-----------------------------------------------------------------------------------
--# File Name    : sess_by_wait_event.sql
--#
--# Description  : Shows basic information about the sessions using given wait event name.
--#
--# Call Syntax  : @sess_by_wait_event (wait-event-name)
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

Prompt
Prompt ##
Prompt ## Sessions info based on provided wait event:
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
and    s.type<>'BACKGROUND'
and    s.event='&1'
order  by s.logon_time desc;

Prompt
Prompt Note: use "sess_info.sql" script to get more detailed information about the particular session.
Prompt
