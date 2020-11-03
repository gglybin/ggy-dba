--#-----------------------------------------------------------------------------------
--# File Name    : disable_trace_for_curr_user_sess.sql
--#
--# Description  : Disable trace for already connected sessions.
--#
--# Call Syntax  : SQL> @disable_trace_for_curr_user_sess.sql (user-name)
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;
set serveroutput on;

begin
  dbms_output.put_line(chr(1));
  dbms_output.put_line('Disabled trace for below sessions: ');
  dbms_output.put_line('---------------------------------');
  dbms_output.put_line(chr(1));
  for i in (select s.sid
                   ,s.serial#
                   ,s.username
                   ,s.schemaname
                   ,s.osuser
                   ,p.spid
                   ,s.machine
            from   v$session s,
                   v$process p
            where  s.paddr=p.addr
            and    s.username='&&1'
             ) loop 
        dbms_monitor.session_trace_disable(i.sid, i.serial#);
        dbms_output.put_line('SID = '||i.sid||', SERIAL# = '||i.serial#||', OS_PID = '||i.spid||', USERNAME = '||i.username||', SCHEMA_NAME = '||i.schemaname||', MACHINE = '||i.machine);
        dbms_output.put_line(chr(1));
end loop;
end;
/

set serveroutput off;

Prompt
Prompt Note: this script can be adjusted by correcting query in the loop to trace sessions based on client machine for example.
Prompt
Prompt Note: use "enable_trace_for_curr_user_sess.sql" script to enable trace for all user sessions.
Prompt
Prompt Note: trace files can be found here $ ls -ltr <diagnostic_dest>/diag/rdbms/<db_name>/<oracle_sid>/trace/<oracle_sid>_ora*.trc 
Prompt
