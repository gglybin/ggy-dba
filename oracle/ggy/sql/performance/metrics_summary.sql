--#-----------------------------------------------------------------------------------
--# File Name     : metrics_summary.sql
--#
--# Description   : Shows database system metrics for last 1 hour.
--#
--# Call Syntax   : @metrics_summary.sql
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

col metric_unit for a30
col metric_name for a50

select to_char(begin_time, 'DD-MON-YY HH24:MI') "BEGIN_TIME"
       ,to_char(end_time, 'DD-MON-YY HH24:MI') "END_TIME"
       ,metric_unit
       ,metric_name
       ,round(average,5) "AVERAGE"
       ,round(standard_deviation,5) "DEVIATION"
       ,round(maxval,5) "MAX"
       ,round(minval ,5) "MIN"
from   v$sysmetric_summary
where  metric_unit in ('Transactions Per Second','Requests Per Second','Queries Per Second','% (LogRead - PhyRead)/LogRead','% Busy/(Idle+Busy)','% Cpu/DB_Time','% Wait/DB_Time','Milliseconds')
order  by metric_unit, metric_name;

prompt Note: to get historical overview - use "dba_hist_sysmetric_history" view.
prompt
