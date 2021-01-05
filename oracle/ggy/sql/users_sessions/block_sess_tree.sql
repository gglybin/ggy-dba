--#-----------------------------------------------------------------------------------
--# File Name    : block_sess_tree.sql
--#
--# Description  : Shows blocking sessions tree.
--#
--# Call Syntax  : SQL> @block_sess_tree
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

col lock_tree for a60
col username for a20
col status for a15
col event for a50
col sql_id for a15
col osuser  for a15
col machine for a30
col program for a30

with sess_info as (select
        s.inst_id
       ,s.username
       ,s.status
       ,s.sid
       ,s.serial#
       ,p.spid
       ,s.sql_id
       ,s.event
       ,s.blocking_session
       ,s.osuser
       ,s.machine
       ,s.program
from   gv$session s,
       gv$process p
where  s.paddr=p.addr)
select
       lpad(' ',(LEVEL-1)*3) || '--> INST_ID: ' || inst_id || ' SID: '|| sid || ' SERIAL: ' || serial# || ' PROCESS: ' || spid as lock_tree
       ,username
       ,status
       ,event
       ,sql_id
--       ,osuser
--       ,machine
--       ,program
from  sess_info
start with sid in (select final_blocking_session from v$session where final_blocking_session_status='VALID')
connect by prior sid = blocking_session;

Prompt
Prompt Note: use "sess_info.sql" script to get more detailed information about the particular session.
Prompt
