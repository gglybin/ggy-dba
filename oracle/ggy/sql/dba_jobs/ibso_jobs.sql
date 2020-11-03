--#-----------------------------------------------------------------------------------
--# File Name    : ibso_jobs.sql
--#
--# Description  : Shows info about IBSO running jobs and its session ids.
--#
--# Call Syntax  : SQL> @ibso_jobs
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## IBSO running jobs:
Prompt ##

-- $ export LANG=en_US.UTF-8
-- $ export NLS_LANG=AMERICAN_AMERICA.UTF8

col os_pid          for a10
col oracle_username for a10
col c_name          for a70
col c_short_name    for a20
col c_submit_user   for a40
col module          for a20
col c_info          for a20
col session_status  for a10

select sess.sid
       ,sess.serial_id
       ,sess.os_pid
       ,sess.session_status
       ,sess.oracle_username
       ,ibsj.c_name
       ,ibsj.c_short_name
       ,ibsj.c_submit_user
       ,ibsj.c_start_time
from   (
         select s.sid sid
                ,s.serial# serial_id
                ,p.spid os_pid
                ,s.status session_status
                ,s.username oracle_username
                ,s.osuser os_username
                ,s.program session_program
                ,s.action
                ,s.module
         from   gv$process p,
                gv$session s
         where  p.addr (+) = s.paddr
         and    s.action = 'SYSTEM_JOBS for IBS'
       ) sess left outer join ibs.z#system_jobs ibsj
                on (substr(sess.module,length(to_char(sess.oracle_username))+2) =  to_char(ibsj.id))
order  by ibsj.c_start_time, c_name nulls last;

/***************
-- Run from TOAD/SQL Developer --
SELECT SESS.SID
       ,SESS.SERIAL_ID
       ,SESS.OS_PID
       ,SESS.SESSION_STATUS
       ,SESS.ORACLE_USERNAME
       ,SESS.SESSION_PROGRAM
       ,SESS.ACTION
       ,SESS.MODULE
       ,NVL(TO_CHAR(IBSJ.ID),'Управляющая ...') ID
       ,IBSJ.CLASS_ID
       ,IBSJ.C_SHORT_NAME
       ,IBSJ.C_NAME
       ,IBSJ.C_JOB
       ,IBSJ.C_START_TIME
       ,IBSJ.C_INFO
       ,IBSJ.C_SUBMIT_USER
FROM   (
         SELECT S.SID SID
                ,S.SERIAL# SERIAL_ID
                ,P.SPID OS_PID
                ,S.STATUS SESSION_STATUS
                ,S.USERNAME ORACLE_USERNAME
                ,S.OSUSER OS_USERNAME
                ,S.PROGRAM SESSION_PROGRAM
                ,S.ACTION
                ,S.MODULE
         FROM   GV$PROCESS P,
                GV$SESSION S
         WHERE  P.ADDR (+) = S.PADDR
         AND    S.ACTION = 'SYSTEM_JOBS for IBS'
       ) SESS LEFT OUTER JOIN IBS.Z#SYSTEM_JOBS IBSJ
                ON (SUBSTR(SESS.MODULE,LENGTH(TO_CHAR(SESS.ORACLE_USERNAME))+2) =  TO_CHAR(IBSJ.ID))
ORDER  BY IBSJ.C_START_TIME;
***************/
