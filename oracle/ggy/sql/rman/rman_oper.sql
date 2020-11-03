--#-----------------------------------------------------------------------------------
--# File Name    : rman_oper.sql
--#
--# Description  : Shows information about current RMAN sessions and estimated timings.
--#
--# Call Syntax  : @rman_oper
--#-----------------------------------------------------------------------------------

set lines 400 pages 32

Prompt
Prompt ##
Prompt ## RMAN Operations status:
Prompt ##

col start_time      for a30

select sid
       ,serial#
       ,to_char(start_time,'DD-MON-YYYY HH24:MI:SS') start_time
       ,elapsed_seconds
       ,time_remaining
       ,context
       ,sofar
       ,totalwork
       ,trunc(time_remaining / 60) "MIN_RESTANTES"
       ,round(sofar / totalwork * 100, 2) "%_COMPLETE"
from   v$session_longops
where  opname like '%RMAN%'
and    totalwork > 0
order  by to_timestamp(start_time,'DD-MON-YYYY HH24:MI:SS');

Prompt
Prompt Note: use "sess_info.sql" script to get more detailed information about the particular session.
Prompt
