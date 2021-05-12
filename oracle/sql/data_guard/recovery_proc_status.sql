--#-----------------------------------------------------------------------------------
--# File Name     : recovery_proc_status.sql
--#
--# Description   : Check data guard processes recovery status.
--#
--# Call Syntax   : SQL> @recovery_proc_status
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Recovery status:
Prompt ##

col process for a10
col status  for a20
col block   for a20

select process
       ,status
       ,sequence#
       ,block#
       ,blocks
       ,delay_mins
from   v$managed_standby
order  by  sequence# desc;

Prompt
Prompt Note: use "dataguard_info.sql" script to get some details about data guard configuration.
Prompt
