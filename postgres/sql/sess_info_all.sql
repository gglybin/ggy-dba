--#-----------------------------------------------------------------------------------
--# File Name    : sess_info_all.sql
--#
--# Description  : Shows basic information about current sessions connected to Postgres cluster.
--#
--# Call Syntax  : psql=# \i sess_info_all.sql
--#-----------------------------------------------------------------------------------

\echo ''

select datname as database_name
       ,backend_start
       ,pid as process_id
       ,usename as username
       ,client_addr as client_address
       ,application_name
       ,backend_type
       ,state
       --,state_change
from   pg_stat_activity
where  backend_type='client backend'
order  by backend_start desc;
