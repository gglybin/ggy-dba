--#-----------------------------------------------------------------------------------
--# File Name     : stby_lag_time.sql
--#
--# Description   : Shows time lag between primary and standby.
--#                 Should be run on  Standby database.
--#
--# Call Syntax   : SQL> @stby_lag_time
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Time Lag:
Prompt ##

col name  for a30
col value for a40

select
       name,
       value
from
       v$dataguard_stats;

/*
Prompt ##
Prompt ## Recovery Rate Stats:
Prompt ##


col START_TIME for a20
col TYPE for a20
col ITEM for a40
col UNITS for a20
col TIMESTAMP for a20
col COMMENTS for a20

select
       to_char(start_time, 'HH24:MI DD-MON-YY') as "START_TIME",
       type,
       item,
       units,
       sofar,
       total,
       timestamp,
       comments
from
       v$recovery_progress
order by item;
*/
