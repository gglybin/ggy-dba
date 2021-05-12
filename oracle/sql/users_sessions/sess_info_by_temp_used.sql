--#-----------------------------------------------------------------------------------
--# File Name    : sess_info_by_temp_used.sql
--#
--# Description  : Shows top 50 sessions ordered by TEMP usage.
--#
--# Call Syntax  : SQL> @sess_info_by_temp_used
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Top 50 sessions ordered by TEMP usage:
Prompt ##

col "SID,SERIAL" for a15
col username     for a20
col schemaname   for a20
col osuser       for a20
col segment_name for a40
col machine      for a50

select *
from (select a.sid||','||a.serial# as "SID,SERIAL"
             ,a.username
             ,a.schemaname
             ,a.osuser
             ,round(((b.blocks*p.value)/1024/1024),2) "USED_MB"
             ,a.sql_id
             ,a.machine
      from   gv$session a,
             gv$sort_usage b,
             gv$parameter p
      where  p.name  = 'db_block_size'
      and    a.saddr = b.session_addr
      and    a.inst_id=b.inst_id
      and    a.inst_id=p.inst_id
     )
where rownum <=50;

Prompt
Prompt Note: use "sess_info.sql" script to get more detailed information about the particular session.
Prompt
