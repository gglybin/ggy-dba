--#-----------------------------------------------------------------------------------
--# File Name    : sql_monitor_report_by_sql_id.sql
--#
--# Description  : Shows SQL Monitor Report using SQL_ID privided.
--#
--# Call Syntax  : SQL> @sql_monitor_report_by_sql_id (sql-id)
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

set linesize 250 pagesize 0 trims on tab off long 1000000;

Prompt
Prompt ##
Prompt ## SQL Monitor Report for &&1:
Prompt ##
Prompt

col report for a250

select dbms_sql_monitor.report_sql_monitor(sql_id => '&&1', report_level => 'ALL') report
from   dual;

Prompt ======
Prompt Notes:
Prompt ======
Prompt
Prompt 1) Information from v$sql_monitor can be flushed quickly on high load databases.
Prompt
Prompt 2) Monitoring SQL Statements with Real-Time SQL Monitoring (Doc ID 1380492.1).
Prompt
Prompt 3) To get query historical overview use "sql_exec_history.sql" script and 2555350.1 for more reports.
Prompt
