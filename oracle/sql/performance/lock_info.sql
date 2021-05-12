--#-----------------------------------------------------------------------------------
--# File Name    : lock_info.sql
--#
--# Description  : Shows information about current locks on objects in database.
--#
--# Call Syntax  : @lock_info
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

col SID_SERIAL   for a15
col BLOCKER_SID  for a10
col USERNAME     for a20
col OWNER_OBJECT for a30
col LOCK_TYPE    for a5
col LOCKED_MODE  for a30
col WAIT_EVENT   for a30
col SESS_STATUS  for a15

select substr(to_char(l.session_id)||','||to_char(s.serial#),1,15) SID_SERIAL
       ,nvl(to_char(s.final_blocking_session),'-') BLOCKER_SID
       ,substr(l.os_user_name||'/'||l.oracle_username,1,20) USERNAME
       ,substr(o.owner||'.'||o.object_name,1,35) OWNER_OBJECT
       ,ll.type LOCK_TYPE
       ,decode(l.locked_mode, 1,'No Lock', 2,'Row Share', 3,'Row Exclusive', 4,'Share', 5,'Share Row Excl', 6,'Exclusive',null) LOCKED_MODE
       ,s.event WAIT_EVENT
       ,substr(s.status,1,10) SESS_STATUS
from   v$lock ll
       ,v$locked_object l
       ,dba_objects o
       ,v$session s
       ,v$process p
where  l.object_id=ll.id1 and l.session_id=ll.sid
and    l.object_id = o.object_id
and    l.session_id = s.sid
and    s.paddr = p.addr
and    s.status != 'KILLED'
order  by o.owner, o.object_name;

Prompt
Prompt Note: use "sess_info.sql" script to get more detailed information about the particular session.
Prompt
