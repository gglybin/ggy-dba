--#-----------------------------------------------------------------------------------
--# File Name    : create_trace_trg.sql
--#
--# Description  : Creates trigger for tracing new logins of particular user.
--#
--# Call Syntax  : SQL> @create_trace_trg (user-name)
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

Prompt
Prompt ##
Prompt ## Creating a trigger for &&1 schema logons:
Prompt ##

create or replace trigger user_trace_trg after logon on database
disable
declare
  SI int;
  SE int;
  FILE_NAME varchar2(200);
begin
   IF USER = '&&1'
   THEN
     select sid,serial# into SI,SE from v$session where audsid = userenv('SESSIONID');
     FILE_NAME:='&&1'||'_'||SI||'_'||SE;
     execute immediate 'alter session set tracefile_identifier = '||FILE_NAME;
     dbms_monitor.session_trace_enable(SI, SE, waits=>true, binds=>true);
   END IF;
EXCEPTION
WHEN OTHERS THEN
NULL;
end;
/

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

Prompt ##
Prompt ## INFO:
Prompt ##

col "Enable" for a50

select 'alter trigger USER_TRACE_TRG enable;' as "Enable"
from   dual;

col "Disable" for a50

select 'alter trigger USER_TRACE_TRG disable;' as "Disable"
from   dual;

col "Stop trace for sessions" for a155
select 'begin for i in ( select sid, serial# from v$session where username=''&&1'' ) loop dbms_monitor.SESSION_TRACE_DISABLE(i.sid, i.serial#); end loop; end;' as "Stop trace for sessions"
from dual;

col "Format" for a100
select '$ tkprof <file>.trc <file>.out sys=no waits=yes aggregate=yes width=180' as "Format"
from dual;
