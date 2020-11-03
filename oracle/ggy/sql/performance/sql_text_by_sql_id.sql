--#-----------------------------------------------------------------------------------
--# File Name    : sql_text_by_sql_id.sql
--#
--# Description  : Find SQL_TEXT using provided SQL_ID.
--#
--# Call Syntax  : SQL> @sql_text_by_sql_id (sql-id)
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

Prompt
Prompt ##
Prompt ## SQL Text (cached):
Prompt ##

col sql_text for a75

select sql_text
from   v$sqltext
where  sql_id='&&1'
order  by piece;

/*
Prompt
Prompt ##
Prompt ## SQL Text (historical):
Prompt ##

set long 5000

select sql_text 
from   dba_hist_sqltext
where  sql_id='&&1';
*/

Prompt ======
Prompt Notes:
Prompt ======
Prompt
Prompt 1) Check "dba_hist_sqltext" view if you got nothing from above.
Prompt
Prompt 2) To get query historical overview use "sql_exec_history.sql" script and 2555350.1 for more reports.
Prompt
Prompt 3) To get query execution plan use "xplan.sql" script.
Prompt
