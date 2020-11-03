--#-----------------------------------------------------------------------------------
--# File Name    : dba_sch_jobs.sql
--#
--# Description  : Shows info about DBA_SCHEDULER jobs defined in database.
--#
--# Call Syntax  : SQL> @dba_sch_jobs
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Jobs:
Prompt ##

col owner     for a20
col job_name  for a30
col job_style for a20
col job_type  for a20
col enabled   for a10
col state     for a20

select owner
       ,job_name
       ,job_style
       ,job_type
       ,job_priority
       ,enabled
       ,state
from   dba_scheduler_jobs
--where  owner not in ('SYS','SYSTEM')
order  by owner, job_name;

Prompt
Prompt Note: use "find_job.sql" to get additional details about specific job.
Prompt
