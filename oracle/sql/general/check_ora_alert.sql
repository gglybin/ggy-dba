--#-----------------------------------------------------------------------------------
--# File Name     : check_ora_alert.sql
--#
--# Description   : Check all entries for %ORA-% like errors.
--#
--# Call Syntax   : SQL> @check_ora_alert (ora-error-mask)
--#
--# Example       : SQL> @check_ora_alert ORA-00600
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

Prompt
Prompt ##
Prompt ## %&&1% entries in alert log:
Prompt ##

col "DATE"                for a20
col message_text          for a100

select to_char(originating_timestamp, 'HH24:MI:SS DD-MON-YYYY') as "DATE"
       ,message_text
from   v$diag_alert_ext
where  message_text like '%&&1%'
order  by originating_timestamp;

/*
Prompt ##
Prompt ## All alert log records for last 1 hour:
Prompt ##

select to_char(originating_timestamp, 'HH24:MI:SS DD-MON-YYYY') as "DATE"
       ,message_text
from   v$diag_alert_ext
where  originating_timestamp > (sysdate - 1/24)
order  by originating_timestamp;
*/
