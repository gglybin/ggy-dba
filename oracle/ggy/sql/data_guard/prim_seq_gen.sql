--#-----------------------------------------------------------------------------------
--# File Name     : prim_seq_gen.sql
--#
--# Description   : Check last generated sequence on Primary.
--#
--# Call Syntax   : SQL> @prim_seq_gen
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Last Generated:
Prompt ##

select thread#
       ,max(sequence#) "LAST_SEQ_GENERATED"
from   v$archived_log
where  first_time between (sysdate-1) and (sysdate+1)
group  by thread#
order  by 1;

Prompt
Prompt Note: use "dataguard_info.sql" script to get some details about data guard configuration.
Prompt
