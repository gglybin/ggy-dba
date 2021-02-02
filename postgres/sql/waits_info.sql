--#-----------------------------------------------------------------------------------
--# File Name    : waits_info.sql
--#
--# Description  : Shows current database sessions wait events.
--#
--# Call Syntax  : psql> \i waits_info.sql
--#-----------------------------------------------------------------------------------

\echo ''

select wait_event_type, wait_event, state, count(*)
from pg_stat_activity
where backend_type='client backend'
and pid not in (select pg_backend_pid())
group by wait_event_type, wait_event, state
order by 4 desc;
