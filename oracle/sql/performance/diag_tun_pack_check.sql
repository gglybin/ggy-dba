--#-----------------------------------------------------------------------------------
--# File Name    : diag_tun_pack_check.sql
--#
--# Description  : Check DIAG+TUNING pack status and usage history.
--#
--# Call Syntax  : @diag_tun_pack_check
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Status
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
where  name='control_management_pack_access';

Prompt ##
Prompt ## Usage History
Prompt ##

col name            for a45
col last_usage_date for a30

select name
       ,detected_usages
       ,last_usage_date
from   dba_feature_usage_statistics
where  name in ('ADDM',
               'Automatic SQL Tuning Advisor',
               'Automatic Workload Repository',
               'AWR Baseline',
               'AWR Baseline Template',
               'AWR Report',
               'EM Performance Page',
               'Real-Time SQL Monitoring',
               'SQL Access Advisor',
               'SQL Monitoring and Tuning pages',
               'SQL Performance Analyzer',
               'SQL Tuning Advisor',
               'SQL Tuning Set (system)',
               'SQL Tuning Set (user)')
order  by detected_usages desc,last_usage_date desc;
