--#-----------------------------------------------------------------------------------
--# File Name    : dba_jobs_running.sql
--#
--# Description  : Shows info about old style jobs in database which are currently running.
--#
--# Call Syntax  : SQL> @dba_jobs_running
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Running Jobs:
Prompt ##

select job
       ,instance
       ,sid
       ,to_char(last_date, 'DD-MON-YY HH24:MI:SS') as "LAST_DATE"
       ,to_char(this_date, 'DD-MON-YY HH24:MI:SS') as "THIS_DATE"
       ,to_char((sysdate - this_date), 'DD-MON-YY HH24:MI:SS') as "DURATION"
from   dba_jobs_running
--where  last_date >= to_date ('20-JUN-19 11:30:00','DD-MON-YY HH24:MI:SS')
order  by last_date, this_date;

Prompt
Prompt Note: use "dba_jobs.sql" to get info about all dba jobs.
Prompt
Prompt Note: run "SQL> exec dbms_job.remove(<<JOB_NUMBER>>);" to remove job.
Prompt
Prompt Note: run "SQL> exec dbms_job.broken(<<<JOB_NUMBER>>, TRUE);" to turn off the job.
Prompt
