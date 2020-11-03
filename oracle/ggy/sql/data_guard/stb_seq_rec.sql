--#-----------------------------------------------------------------------------------
--# File Name     : stb_seq_rec_appl.sql
--#
--# Description   : Shows last received/applied sequence on standby.
--#
--# Call Syntax   : SQL> @stb_seq_rec
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Last Received:
Prompt ##

select thread#
       ,max(sequence#) "LAST_SEQ_RECEIVED"
from   v$archived_log
group  by thread#
order  by 1;

Prompt ##
Prompt ## Last Applied:
Prompt ##

select thread#
       ,max(sequence#) "LAST_SEQ_APPLIED"
from   v$archived_log
where  applied='YES'
group  by thread#
order  by 1;

Prompt
Prompt Note 1: use "dataguard_info.sql" script to get some details about data guard configuration.
Prompt
Prompt Note 2: use "recovery_proc_status.sql" to get recovery processes status.
Prompt
