--#-----------------------------------------------------------------------------------
--# File Name    : awr_settings.sql
--#
--# Description  : Shows current AWR settings (interval, retention, etc).
--#
--# Call Syntax  : @awr_settings
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## AWR settings:
Prompt ##

select extract(day from snap_interval) * 24 * 60 + extract(hour from snap_interval) * 60 + extract(minute from snap_interval) as "Snapshot_Interval [Min]",
       (extract(day from retention) * 24 * 60 + extract(hour from retention) * 60 + extract(minute from retention)) / 60 / 24 as "Retention_Interval [Days]"
from   dba_hist_wr_control
where  dbid in (select dbid from v$database);

Prompt ##
Prompt ## AWR Moving Window:
Prompt ##

select moving_window_size "Moving_Window_Size [Days]" 
from dba_hist_baseline;

Prompt ##
Prompt ## STATISTICS_LEVEL:
Prompt ##

col name             for a45
col value            for a20
col issys_modifiable for a16
col ispdb_modifiable for a16
col isses_modifiable for a16
col description      for a75

select name
       ,value
       ,issys_modifiable
       ,ispdb_modifiable
       ,isses_modifiable
       ,description
from   v$system_parameter2
where  name='statistics_level';

Prompt
Prompt Note: if statistics_level=BASIC then oracle (mmon) will not collect AWR stats automatically.
Prompt
Prompt Note: MOVING_WINDOW_SIZE can NOT be greater then AWR Retention Period. Ref. to 2051358.1.
Prompt

/*
--
-- Use below command to change moving window size
--

exec dbms_workload_repository.modify_baseline_window_size(window_size => 7);

--
-- Use below command to change interval ot retention:
--

exec dbms_workload_repository.modify_snapshot_settings(interval => 15, retention => 10080);   <<<<<<<<<<<<<<< 15 min Interval; 7 Days retention (10080 min)
*/
