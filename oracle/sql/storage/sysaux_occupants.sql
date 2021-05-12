--#-----------------------------------------------------------------------------------
--# File Name    : sysaux_occupants.sql
--#
--# Description  : Shows SYSAUX tablespace occupants and its size.
--#
--# Call Syntax  : @sysaux_occupants
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## SYSAUX Tablespace Occupants:
Prompt ##

col schema_name   for a20
col occupant_name for a40
col occupant_desc for a60

select schema_name
       ,occupant_name
       ,occupant_desc
       ,round((space_usage_kbytes/1024),3) "SIZE_MB"
from   v$sysaux_occupants
order  by space_usage_kbytes desc;

Prompt
Prompt Note: use "awr_settings.sql" to check current instance AWR settings.
Prompt 
Prompt Note: use "tbs_top_segments.sql" script to check largest segments on SYSAUX tablespace.
Prompt
Prompt Note: use "Troubleshooting Issues with SYSAUX Space Usage (Doc ID 1399365.1)" to investigate and fix SYSAUX space issues.
Prompt
