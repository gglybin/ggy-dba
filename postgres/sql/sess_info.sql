--#-----------------------------------------------------------------------------------
--# File Name    : sess_info.sql
--#
--# Description  : Shows basic info about database session.
--#
--# Call Syntax  : bash$ psql -v pid=\'12345\' -f sess_info.sql
--#-----------------------------------------------------------------------------------

\echo ''
\echo '##'
\echo '## Session info:'
\echo '##'
\echo ''

\x

select *
from   pg_stat_activity
where  pid = :pid;

\x
