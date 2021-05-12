--#-----------------------------------------------------------------------------------
--# File Name    : status_trace_trg.sql
--#
--# Description  : Checks trace trigger (USER_TRACE_TRG) status.
--#
--# Call Syntax  : SQL> @status_trace_trg
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

Prompt
Prompt ##
Prompt ## Trigger status:
Prompt ##

col owner         for a10
col trigger_name  for a15
col trigger_type  for a12
col status        for a10
col "CREATE_TIME" for a20
col "MODIFIED"    for a20

select owner
       ,trigger_name
       ,trigger_type
       ,status
       ,to_char((select created from dba_objects where object_name='USER_TRACE_TRG' and object_type='TRIGGER'),'HH24:MI DD-MON-YY') as "CREATED"
       ,to_char((select last_ddl_time from dba_objects where object_name='USER_TRACE_TRG' and object_type='TRIGGER'),'HH24:MI DD-MON-YY') as "MODIFIED"
from   dba_triggers 
where  trigger_name='USER_TRACE_TRG';

Prompt
Prompt Note: use "ddl_trace_trg.sql" script to get current trigger version DDL.
Prompt
Prompt Note: use "enable_trace_trg.sql" script to enable trigger.
Prompt
Prompt Note: use "disable_trace_trg.sql" script to disable trigger.
Prompt
Prompt Note: use "disable_trace_for_curr_user_sess.sql" script to disable trace for sessions.
Prompt
