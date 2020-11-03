--#-----------------------------------------------------------------------------------
--# File Name    : sql_id_by_sql_text.sql
--#
--# Description  : Find SQL_ID using part of the SQL_TEXT.
--#
--# Call Syntax  : SQL> @sql_id_by_sql_text "some sql text here"
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

Prompt
Prompt ##
Prompt ## SQL ID (check from cache):
Prompt ##

col sql_id       for a20

select sql_id
       ,child_number
from   v$sql
where  sql_text like '%&&1%';

/*
Prompt
Prompt ##
Prompt ## SQL ID (historical):
Prompt ##

col sql_id for a20

select sql_id
from   dba_hist_sqltext
where  sql_text like '%&&1%';
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
