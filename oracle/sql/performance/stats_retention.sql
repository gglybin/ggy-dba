--#-----------------------------------------------------------------------------------
--# File Name    : stats_retention.sql
--#
--# Description  : Checks Optimazer stats history retention.
--#
--# Call Syntax  : @stats_retention
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

select dbms_stats.get_stats_history_retention "STATS_RETENTION [DAYS]"
from   dual;
