--#-----------------------------------------------------------------------------------
--# File Name    : sess_info_by_pga_usage.sql
--#
--# Description  : Shows PGA settings and top 50 sessions ordered by PGA usage.
--#
--# Call Syntax  : @sess_info_by_pga_usage
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Total:
Prompt ##

select round(sum(pga_used_mem)/(1024*1024),2) PGA_USED_MB
from   v$process;

Prompt ##
Prompt ## PGA parameters:
Prompt ##

col name             for a45
col value            for a20
col issys_modifiable for a16
col ispdb_modifiable for a16
col isses_modifiable for a16
col description      for a75

select name
       ,value
       ,issys_modifiable
       ,ispdb_modifiable
       ,isses_modifiable
       ,description
from   v$system_parameter2
where  name like 'pga%';

Prompt ##
Prompt ## Top 50 sessions (exclude background processes):
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
            ,round(p.pga_used_mem/(1024*1024), 2) PGA_MB_USED
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
     order  by pga_used_mem desc
    )
where rownum <= 50;

Prompt
Prompt Note: use "sess_info.sql" script to get more detailed information about the particular session.
Prompt
Prompt Note: Limiting Process Size with Database Parameter PGA_AGGREGATE_LIMIT (Doc ID 1520324.1)
Prompt
