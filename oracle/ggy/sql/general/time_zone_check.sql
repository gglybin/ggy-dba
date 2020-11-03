--#-----------------------------------------------------------------------------------
--# File Name    : time_zone_check.sql
--#
--# Description  : Shows current time zone.
--#
--# Call Syntax  : @time_zone_check
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Time Zone version:
Prompt ##

col filename for a30

select *
from   v$timezone_file;

Prompt ##
Prompt ## Useful docs:
Prompt ##
Prompt
Prompt 1) Updated DST Transitions and New Time Zones in Oracle RDBMS and OJVM Time Zone File Patches (Doc ID 412160.1)
Prompt 2) https://oracle-base.com/articles/misc/update-database-time-zone-file
Prompt
