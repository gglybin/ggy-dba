--#-----------------------------------------------------------------------------------
--# File Name    : sess_info_all.sql
--#
--# Description  : Shows basic information about current sessions in database.
--#
--# Call Syntax  : @sess_info_all
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

Prompt
Prompt ##
Prompt ## Sessions count:
Prompt ##

col status for a20
col type   for a20

break on report
compute sum label 'Total' of COUNT on report

select type
       ,status
       ,count(*) "COUNT"
from   v$session
group  by type, status
order  by type, status;

Prompt ##
Prompt ## Processes usage:
Prompt ##

col "MAX"     for a15

select max_process "MAX"
       ,round(100*(proc_count/max_process)) "USED_%"
       ,proc_count "CURRENT"
from (select count(*) proc_count from v$session)
     ,(select value max_process from v$system_parameter2 where name='processes');

Prompt ##
Prompt ## Sessions grouped by machine:
Prompt ##

col username   for a30
col machine    for a80
col schemaname for a30

break on report
compute sum label 'Total' of COUNT on report

select username
       ,schemaname
       ,machine
       ,count(*) "COUNT"
from   v$session
--where  username not in ('SYS','SYSTEM')
group  by username, schemaname, machine
order  by 4 desc;

Prompt ##
Prompt ## Top 50 users sessions (exclude background processes):
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

select *
from
    (
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
     order  by s.logon_time desc
    )
where rownum <= 50;

Prompt
Prompt Note: use "sess_info.sql" script to get more detailed information about the particular session.
Prompt
