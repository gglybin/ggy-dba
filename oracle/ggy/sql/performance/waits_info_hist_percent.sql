--#-----------------------------------------------------------------------------------
--# File Name   : waits_info_hist_percent.sql
--#
--# Description : Shows information about sessions wait events in past.
--#
--# Call Syntax : @waits_info_hist_percent (start-date) (end-date)
--#
--#               @waits_info_hist_percent "11:00:00 19/06/2019" "11:15:00 19/06/2019"
--#-----------------------------------------------------------------------------------
 
set lines 400 pages 1000;
set verify off;
 
Prompt
Prompt ##
Prompt ## Events Percentage:
Prompt ##
 
col sample_time for a30
col wait_class for a30
col "EVENT" for a70
 
select
        decode(event,'null event','ON CPU',null,'ON CPU',event) event
       ,round(100*count(*)/sum(count(*))over(), 1) pct_total
from
       dba_hist_active_sess_history ash
where
       sample_time between to_date('&&1','HH24:MI:SS DD/MM/YYYY') and to_date('&&2','HH24:MI:SS DD/MM/YYYY')
group
       by decode(event,'null event','ON CPU',null,'ON CPU',event)
order
       by count(*) desc;
