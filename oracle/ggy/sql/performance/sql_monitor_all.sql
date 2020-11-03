--#-----------------------------------------------------------------------------------
--# File Name    : sql_monitor_all.sql
--#
--# Description  : Shows all queries captured by SQL Monitor and sorts by execution start.
--#
--# Call Syntax  : SQL> @sql_monitor_all
--#-----------------------------------------------------------------------------------

set lines 400 pages 20;
set verify off;

Prompt
Prompt ##
Prompt ## SQL Monitor:
Prompt ##

col "START_TIME"  for a20
col "END_TIME"    for a20
col ERROR_MESSAGE for a20
select sql_id
       ,sql_exec_id
       ,sql_plan_hash_value
       ,to_char(sql_exec_start, 'HH24:MI:SS DD-MON-YYYY') "START_TIME"
       ,decode(status,'EXECUTING',NULL,to_char((sql_exec_start + numtodsinterval((elapsed_time / 1000000),'second')),'HH24:MI:SS DD-MON-YYYY')) "END_TIME"
       ,round((elapsed_time / 1000000), 5) "TOTAL_TIME_SEC"
       ,round((cpu_time / 1000000), 5) "CPU_TIME_SEC"
       ,round((user_io_wait_time / 1000000), 5) "IO_TIME_SEC"
       ,round((concurrency_wait_time / 1000000), 5) "CONCURR_TIME_SEC"
       ,round(((elapsed_time - cpu_time - user_io_wait_time) / 1000000),4) "OTHER_WAIT_TIME_SEC"
       ,status
--     ,error_message
from   v$sql_monitor
--
-- Running Only      -- where  status='EXECUTING'
-- 
-- Specific interval -- where sql_exec_start >= to_date ('2020/01/31 00:00:00','YYYY/MM/DD HH24:MI:SS')
--
order  by sql_exec_start;

Prompt ======
Prompt Notes:
Prompt ======
Prompt
Prompt 1) Information from v$sql_monitor can be flushed quickly on high load databases.
Prompt
Prompt 2) Monitoring SQL Statements with Real-Time SQL Monitoring (Doc ID 1380492.1).
Prompt
Prompt 3) To get SQL Monitor Report for specific SQL_ID use "sql_monitor_report_by_sql_id.sql" script.
Prompt
Prompt 4) To get query historical overview use "sql_exec_history.sql" script and 2555350.1 for more reports.
Prompt
Prompt 5) To get query SQL_TEXT use "sql_text_by_sql_id.sql" script.
Prompt
Prompt 6) To get query execution plan use "xplan.sql" script.
Prompt
