--#-----------------------------------------------------------------------------------
--# File Name    : redo_status_size_info.sql
--#
--# Description  : Shows basic information about redo log file (size, path, etc).
--#
--# Call Syntax  : @redo_status_size_info
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Redo logs:
Prompt ##

col member for a75
col status for a10

break on report
compute sum label 'Total' of SIZE_MB on report

select a.group#
       ,b.type
       ,b.member
       ,a.status
       ,(a.bytes / 1024 / 1024) SIZE_MB
from   gv$log a,
       gv$logfile b
where  a.group#=b.group#
order  by 1, 3;

Prompt ##
Prompt ## Standby logs:
Prompt ##

break on report
compute sum label 'Total' of SIZE_MB on report

select a.group#
       ,b.type
       ,b.member
       ,a.status
       ,(a.bytes / 1024 / 1024) SIZE_MB
from   gv$standby_log a,
       gv$logfile b
where  a.group#=b.group#
order  by 1, 3;
