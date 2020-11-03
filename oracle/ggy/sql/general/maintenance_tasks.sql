--#-----------------------------------------------------------------------------------
--# File Name    : maintenance_tasks.sql
--#
--# Description  : Short info about maintenance tasks and it's schedule.
--#
--# Call Syntax  : @maintenance_tasks
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Tasks status:
Prompt ##

col client_name     for a35
col task_name       for a45
col status          for a20
col last_try_date   for a45
col last_try_result for a20

select client_name
       ,task_name
       ,status
       ,last_try_date
       ,last_try_result
from   dba_autotask_task;

select client_name
       ,status
from   dba_autotask_client;

Prompt ##
Prompt ## Tasks status for each Maintenance Window: 
Prompt ##

col window_name      for a30
col window_next_time for a50
col window_active    for a20
col autotask_status  for a20
col optimizer_stats  for a20
col segment_advisor  for a20
col sql_tune_advisor for a20

select *
from   dba_autotask_window_clients;

Prompt ##
Prompt ## Schedule details for next 7 days:
Prompt ##

col start_time for a60
col duration   for a40
select * 
from (
      select *
      from dba_autotask_schedule
      order by start_time
     ) 
where rownum <= 7;
