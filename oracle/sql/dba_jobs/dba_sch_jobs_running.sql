--#-----------------------------------------------------------------------------------
--# File Name    : dba_sch_jobs_running.sql
--#
--# Description  : Shows which database scheduled jobs are running now.
--#
--# Call Syntax  : SQL> @dba_sch_jobs_running
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Running Jobs:
Prompt ##

col owner            for a20
col job_name         for a30
col job_style        for a20
col slave_os_process_id for a20
col elapsed_time        for a30

select running_instance
       ,owner
       ,job_name
       ,job_style
       ,session_id
       ,slave_process_id
       ,slave_os_process_id
       ,elapsed_time
from   dba_scheduler_running_jobs
-- where  owner not in ('SYS','SYSTEM')
order  by owner, job_name;

Prompt
Prompt Note: use "find_job.sql" to get additional details about specific job.
Prompt
Prompt Note: use "sess_info.sql" script to get more detailed information about the job session.
Prompt
