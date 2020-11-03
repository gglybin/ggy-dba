--#-----------------------------------------------------------------------------------
--# File Name    : kill_session.sql
--#
--# Description  : Kills database session.
--#
--# Call Syntax  : bash$ psql -v pid=12345 -f kill_session.sql
--#
--# References   : https://stackoverflow.com/questions/5108876/kill-a-postgresql-session-connection#:~:text=You%20can%20use%20pg_terminate_ba
--#                ckend(),all%20operating%20systems%20the%20same
--#-----------------------------------------------------------------------------------

select pg_terminate_backend(:pid);

/*

--
-- Multi-kill:
--

\echo ''
\echo '##'
\echo '## Going to kill session(s) below:'
\echo '##'
\echo ''

select datname as database_name
       ,backend_start
       ,pid as process_id
       ,usename as username
       ,client_addr as client_address
       ,application_name
       ,backend_type
       ,state
from   pg_stat_activity
where
       -- don't kill my own connection!
       pid <> pg_backend_pid()
       -- don't kill the connections to other databases
       and datname = 'apps'
       and backend_type='client backend'
       -- and username='user_name'
       -- and client_addr='10.10.10.10'
       ;

\echo ''
\echo 'Waiting 10 sec ...'
\echo ''
\echo 'Press Ctrl+C to cancel script.'
\echo ''

select pg_sleep(10);

select pg_terminate_backend(pid)
from   pg_stat_activity
where
       -- don't kill my own connection!
       pid <> pg_backend_pid()
       -- don't kill the connections to other databases
       and datname = 'apps'
       and backend_type='client backend'
       -- and username='user_name'
       -- and client_addr='10.10.10.10'
       ;

\echo ''
\echo '##'
\echo '## Check session(s) again:'
\echo '##'
\echo ''

select datname as database_name
       ,backend_start
       ,pid as process_id
       ,usename as username
       ,client_addr as client_address
       ,application_name
       ,backend_type
       ,state
from   pg_stat_activity
where
       -- don't kill my own connection!
       pid <> pg_backend_pid()
       -- don't kill the connections to other databases
       and datname = 'apps'
       and backend_type='client backend'
       -- and username='user_name'
       -- and client_addr='10.10.10.10'
       ;

*/
