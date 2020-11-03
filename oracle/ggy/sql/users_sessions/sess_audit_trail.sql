--#-----------------------------------------------------------------------------------
--# File Name    : sess_audit_trail.sql
--#
--# Description  : Shows information from DBA_AUDIT_TRAIL view. Usually used to check last logins and its status.
--#
--# Call Syntax  : @sess_audit_trail
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Last 50 logins:
Prompt ##

col os_username for a30
col username    for a30
col userhost    for a50
col action_name for a20
col "TIME"      for a30

select * 
from   (select os_username
               ,username
               ,userhost
               ,action_name
               ,returncode
               ,to_char(extended_timestamp,'MM-DD-YYYY HH24:MI:SS') "TIME"
        from   dba_audit_trail
        order  by extended_timestamp desc
       ) dat
where  rownum <= 50
order  by dat.time;

/*
Prompt ##
Prompt ## Filtered:
Prompt ##

select os_username
       ,username
       ,userhost
       ,action_name
       ,returncode
       ,to_char(extended_timestamp,'MM-DD-YYYY HH24:MI:SS') "TIME"
from   dba_audit_trail
where  returncode<>XXXXXXXXXXXXXX
and    username='XXXXXXXXXXXXXX'
and    extended_timestamp >= to_date ('XXXXXXXXXXXXXX','HH24:MI:SS DD/MM/YYYY')
and    extended_timestamp <= to_date ('XXXXXXXXXXXXXX','HH24:MI:SS DD/MM/YYYY')
order  by extended_timestamp;
*/
