--#-----------------------------------------------------------------------------------
--# File Name    : waits_info.sql
--#
--# Description  : Shows information about current wait events in database (exclude idle events).
--#
--# Call Syntax  : @waits_info
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

col event for a60

select event
       ,count(*) as sess_count 
from   gv$session s
       ,gv$event_name e
where  s.event=e.name
and    e.wait_class<>'Idle'
and    e.name<>'SQL*Net message to client'
group  by event
order  by sess_count desc;

Prompt
Prompt Note: use "sess_by_wait_event.sql" script to get list of sessions with particular wait event.
Prompt
