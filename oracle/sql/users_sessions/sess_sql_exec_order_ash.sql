--#---------------------------------------------------------------------------------------------
--# File Name    : sess_sql_exec_order_ash.sql
--#
--# Description  : Show SQL statements execution order for provided session in past.
--#
--# Call Syntax  : SQL> @sess_sql_exec_order_ash (session-sid) (session-serial) (user-name)
--#---------------------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

Prompt
Prompt ##
Prompt ## Session SQL Executions History:
Prompt ##

col sample_time   for a25
col "SID,SERIAL#" for a15
col session_type  for a15
col sql_id        for a15
col sql_opname    for a20
col "EVENT"       for a60
col wait_class    for a30

select user_id
       ,session_id || ',' || session_serial# "SID,SERIAL#"
       ,sql_id
       ,sql_exec_id
       ,sql_plan_hash_value
       ,sql_opname
       ,to_char(min(sql_exec_start), 'HH24:MI:SS DD-MON-YYYY') "START_TIME"
       ,to_char(max(sample_time), 'HH24:MI:SS DD-MON-YYYY') "END_TIME"
       ,to_char((max(sample_time) - min(sql_exec_start)), 'HH24:MI:SS DD-MON-YYYY') "ELAPSED_TIME"
from   v$active_session_history
--from dba_hist_active_sess_history
where  session_id=&&1
and    session_serial#=&&2
and    user_id=(select user_id from dba_users where username='&&3')
group  by session_id, session_serial#, user_id, sql_id, sql_exec_id, sql_plan_hash_value, sql_opname
order  by min(sql_exec_start);

Prompt
Prompt * Note: use "sql_text_by_sql_id.sql" script to get query sql_text.
Prompt *       use "xplan.sql" script to get query execution plan.
Prompt
