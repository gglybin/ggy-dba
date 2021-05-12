--#-----------------------------------------------------------------------------------
--# File Name    : dba_jobs.sql
--#
--# Description  : Shows info about old style jobs in database.
--#
--# Call Syntax  : SQL> @dba_jobs
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Info:
Prompt ##

col log_user    for a20
col schema_user for a20
col "LAST_DATE" for a20
col "THIS_DATE" for a20
col "NEXT_DATE" for a20
col interval    for a20
col broken      for a10
col what        for a30

select instance
       ,job
       ,log_user
       ,schema_user
       ,to_char(last_date, 'DD-MON-YY HH24:MI:SS') as "LAST_DATE"
       ,nvl(to_char(this_date, 'DD-MON-YY HH24:MI:SS'), 'Not running') as "THIS_DATE"
       ,to_char(next_date, 'DD-MON-YY HH24:MI:SS') as "NEXT_DATE"
       ,total_time
       ,interval
       ,failures
       ,broken
       ,what
from   dba_jobs
-- where  last_date >= to_date ('20-JUN-19 11:30:00','DD-MON-YY HH24:MI:SS')
order  by last_date, next_date; 

Prompt
Prompt Note: use "dba_jobs_running.sql" to get info about running dba jobs.
Prompt
Prompt Note: run "SQL> exec dbms_job.remove(<<JOB_NUMBER>>);" to remove job.
Prompt
Prompt Note: run "SQL> exec dbms_job.broken(<<<JOB_NUMBER>>, TRUE);" to turn off the job.
Prompt
