--#-----------------------------------------------------------------------------------
--# File Name    : find_job.sql
--#
--# Description  : Shows info about the job from DBA_SCHEDULER% views.
--#
--# Call Syntax  : SQL> @find_job (job-name)
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

Prompt
Prompt ##
Prompt ## Job Info:
Prompt ##

col owner       for a20
col job_name    for a20
col job_style   for a20
col job_creator for a20
col job_type    for a20
col job_class   for a20
col enabled     for a10
col state       for a20

select owner
       ,job_name
       ,job_style
       ,job_creator
       ,job_type
       ,job_class
       ,job_priority
       ,enabled
       ,state
from   dba_scheduler_jobs
where  job_name like '&&1';

Prompt ##
Prompt ## Job Schedule:
Prompt ##

col "SCH_OWNER"       for a10
col "SCH_TYPE"        for a10
col start_date        for a20
col repeat_interval   for a30
col last_start_date   for a20
col last_run_duration for a30
col next_run_date     for a20

select job_name
       ,schedule_owner as "SCH_OWNER"
       ,schedule_type as "SCH_TYPE"
       ,to_char(start_date, 'DD-MON-YY HH24:MI:SS') as "START_DATE"
       ,repeat_interval
       ,to_char(last_start_date, 'DD-MON-YY HH24:MI:SS') as "LAST_START_DATE"
       ,last_run_duration
       ,to_char(next_run_date, 'DD-MON-YY HH24:MI:SS') as "NEXT_RUN_DATE"
from   dba_scheduler_jobs
where  job_name like '&&1';

Prompt ##
Prompt ## Job Action:
Prompt ##

col job_action for a100

select job_action
from   dba_scheduler_jobs
where  job_name like '&&1';

Prompt ##
Prompt ## Running History (last 50 runs):
Prompt ##

col "REQ_START_DATE" for a20
col "ACT_START_DATE" for a20
col run_duration     for a30
col status           for a20
col session_id       for a20

select *
from (select 
             instance_id
             ,owner
             ,job_name
             ,session_id
             ,to_char(req_start_date, 'DD-MON-YY HH24:MI:SS') as "REQ_START_DATE"
             ,to_char(actual_start_date, 'DD-MON-YY HH24:MI:SS') as "ACT_START_DATE"
             ,run_duration
             ,status
             ,error#
      from   dba_scheduler_job_run_details
      where  job_name like '&&1'
      order by actual_start_date desc
     )
where rownum <= 50;
