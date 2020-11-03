--#-----------------------------------------------------------------------------------
--# File Name    : response_time.sql
--#
--# Description  : Shows Response Time of the database and some additional metrics for last few mins.
--#
--# Call Syntax  : SQL> @response_time
--#
--# References   : https://blog.pythian.com/do-you-know-if-your-database-slow/
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set linesize 60;
set head off;

select
'===================== Metrics =====================',
'Response Time ..................................... '|| rt_value || ' ms',
'TPS [Transactions Per Second] ..................... '|| tps_value,
'RPS [Requests Per Second] ......................... '|| rps_value,
'QPS [Queries Per Second] .......................... '|| qps_value,
'Average Synchronous Single-Block Read Latency ..... '|| round(sbrl_value,4) ||' ms',
'Wait / DB_Time .................................... '|| wdbt_value ||' %'
from (
       select round(value,2) rt_value
       from   v$sysmetric
       where  metric_name='SQL Service Response Time'
     ) rt,
     (
       select round(avg(value),2) tps_value
       from   v$sysmetric
       where  metric_unit='Transactions Per Second'
       and    begin_time >= (sysdate - 6/(24*60))
     ) tps,
     (
       select round(avg(value),2) rps_value
       from   v$sysmetric
       where  metric_unit='Requests Per Second'
       and    begin_time >= (sysdate - 6/(24*60))
     ) rps,
     (
       select round(avg(value),2) qps_value
       from   v$sysmetric
       where  metric_unit='Queries Per Second'
       and    begin_time >= (sysdate - 6/(24*60))
     ) qps,
     (
       select avg(value) sbrl_value
       from   v$sysmetric
       where  metric_unit='Milliseconds'
       and    begin_time >= (sysdate - 6/(24*60))
     ) sbrl,
     (
       select round(avg(value),2) wdbt_value
       from   v$sysmetric
       where  metric_unit='% Wait/DB_Time'
       and    begin_time >= (sysdate - 6/(24*60))
     ) wdbt;

Prompt Note: to get historical overview - use "dba_hist_sysmetric_history" view.
Prompt
