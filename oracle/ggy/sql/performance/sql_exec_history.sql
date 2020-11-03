--#-----------------------------------------------------------------------------------
--# File Name    : sql_exec_history.sql
--#
--# Description  : Show sql execution history using given SQL_ID.
--#
--# Call Syntax  : SQL> @sql_exec_history (sql-id)
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

Prompt
Prompt ###############################
Prompt ## History:
Prompt ###############################

select *
from (select ss.instance_number node
             ,ss.snap_id
             ,to_char(begin_interval_time, 'HH24:MI:SS DD-MON-YYYY') "BEGIN_INT_TIME"
             ,to_char(end_interval_time, 'HH24:MI:SS DD-MON-YYYY') "END_INT_TIME"
             ,sql_id
             ,plan_hash_value
             ,nvl(executions_delta,0) "EXEC_COUNT"
             ,round(((elapsed_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta))/1000000),5) "AVG_EXEC_TIME_SEC"
      from   dba_hist_sqlstat s
             ,dba_hist_snapshot ss
      where  sql_id = '&&1'
      and    ss.snap_id = S.snap_id
      and    ss.instance_number = S.instance_number
      and    executions_delta > 0
      order  by ss.snap_id desc
	  )
where rownum <= 100;

Prompt ###############################
Prompt ## ASH History:
Prompt ###############################

select *
from  (select sql_id
              ,sql_exec_id
              ,sql_plan_hash_value
              ,to_char(min(sql_exec_start), 'HH24:MI:SS DD-MON-YYYY') "START_TIME"
              ,to_char(max(sample_time), 'HH24:MI:SS DD-MON-YYYY') "END_TIME"
              ,to_char((max(sample_time) - min(sql_exec_start)), 'HH24:MI:SS DD-MON-YYYY') "ELAPSED_TIME"
       -- from   v$active_session_history
       from   dba_hist_active_sess_history
       where  sql_id='&&1'
       group  by sql_id, sql_exec_id, sql_plan_hash_value
       order  by min(sql_exec_start) desc
      )
where rownum <= 100;

/*
-- From Doc 1371778.1

-- Memory
set pages 1000 lines 200
col first_load_time for a20
col last_load_time for a20
col outline_category for a20
col sql_profile for a32
select sql_id, child_number, plan_hash_value, first_load_time, last_load_time,
outline_category, sql_profile, executions,
trunc(decode(executions, 0, 0, rows_processed/executions)) rows_avg,
trunc(decode(executions, 0, 0, fetches/executions)) fetches_avg,
trunc(decode(executions, 0, 0, disk_reads/executions)) disk_reads_avg,
trunc(decode(executions, 0, 0, buffer_gets/executions)) buffer_gets_avg,
trunc(decode(executions, 0, 0, cpu_time/executions)) cpu_time_avg,
trunc(decode(executions, 0, 0, elapsed_time/executions)) elapsed_time_avg,
trunc(decode(executions, 0, 0, application_wait_time/executions)) apwait_time_avg,
trunc(decode(executions, 0, 0, concurrency_wait_time/executions)) cwait_time_avg,
trunc(decode(executions, 0, 0, cluster_wait_time/executions)) clwait_time_avg,
trunc(decode(executions, 0, 0, user_io_wait_time/executions)) iowait_time_avg,
trunc(decode(executions, 0, 0, plsql_exec_time/executions)) plsexec_time_avg,
trunc(decode(executions, 0, 0, java_exec_time/executions)) javexec_time_avg
from v$sql
where sql_id = '&sql_id'
order by sql_id, child_number;

-- AWR
set pages 1000 lines 200
col sql_profile for a32
select sql_id, snap_id, plan_hash_value, sql_profile, executions_total,
trunc(decode(executions_total, 0, 0, rows_processed_total/executions_total)) rows_avg,
trunc(decode(executions_total, 0, 0, fetches_total/executions_total)) fetches_avg,
trunc(decode(executions_total, 0, 0, disk_reads_total/executions_total)) disk_reads_avg,
trunc(decode(executions_total, 0, 0, buffer_gets_total/executions_total)) buffer_gets_avg,
trunc(decode(executions_total, 0, 0, cpu_time_total/executions_total)) cpu_time_avg,
trunc(decode(executions_total, 0, 0, elapsed_time_total/executions_total)) elapsed_time_avg,
trunc(decode(executions_total, 0, 0, iowait_total/executions_total)) iowait_time_avg,
trunc(decode(executions_total, 0, 0, clwait_total/executions_total)) clwait_time_avg,
trunc(decode(executions_total, 0, 0, apwait_total/executions_total)) apwait_time_avg,
trunc(decode(executions_total, 0, 0, ccwait_total/executions_total)) ccwait_time_avg,
trunc(decode(executions_total, 0, 0, plsexec_time_total/executions_total)) plsexec_time_avg,
trunc(decode(executions_total, 0, 0, javexec_time_total/executions_total)) javexec_time_avg
from dba_hist_sqlstat
where sql_id = '&sql_id'
order by sql_id, snap_id;
*/

Prompt ======
Prompt Notes:
Prompt ======
Prompt
Prompt 1) To get query sql_text use "sql_text_by_sql_id.sql" script.
Prompt
Prompt 2) To get query execution plan use "xplan.sql" script.
Prompt
Prompt ============
Prompt Useful Docs:
Prompt ============
Prompt => How to get execution statistics and history for a SQL (Doc ID 1371778.1)
Prompt => How To Get Historical SQL Monitor Report For SQL Statements (Doc ID 2555350.1)
Prompt
