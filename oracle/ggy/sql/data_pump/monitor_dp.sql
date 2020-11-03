--#-----------------------------------------------------------------------------------
--# File Name              : monitor_dp.sql
--#
--# Description            : Shows information about current Data Pump sessions and estimated timings.
--#
--# Call Syntax            : SQL> @monitor_dp
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Data Pump session(s) status:
Prompt ##

col opname        for a20
col start_time    for a30
col "SID/SERIAL#" for a15


select opname
       ,sid||','||serial# as "SID/SERIAL#"
       ,to_char(start_time,'DD-MON-YYYY HH24:MI:SS') start_time
       ,elapsed_seconds
       ,time_remaining
       ,context
       ,sofar
       ,totalwork
       ,trunc(time_remaining / 60) "MIN_RESTANTES"
       ,round(sofar / totalwork * 100, 2) "%_COMPLETE"
from   v$session_longops
where  opname like '%IMPORT%' or opname like '%EXPORT%'
and    totalwork > 0
order  by to_timestamp(start_time,'DD-MON-YYYY HH24:MI:SS');

/*
Prompt ##
Prompt ## Additional:
Prompt ##

col "DATE" for a20
col program for a50
col status for a10
col username for a20
col job_name for a30
col event for a20

select to_char(sysdate,'YYYY-MM-DD HH24:MI:SS') "DATE"
       ,s.program
       ,s.sid||','||s.serial# "SID/SERIAL#"
       ,p.pid
       ,s.status
       ,s.username
       ,d.job_name
       ,s.event
from   v$session s
       ,v$process p
       ,dba_datapump_sessions d
where  p.addr=s.paddr 
and    s.saddr=d.saddr;
*/

Prompt
Prompt Note: use "sess_info.sql" script to get more detailed information about the particular session.
Prompt
