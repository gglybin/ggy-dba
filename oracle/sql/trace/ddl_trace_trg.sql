--#-----------------------------------------------------------------------------------
--# File Name    : ddl_trace_trg.sql
--#
--# Description  : Shows trace trigger (USER_TRACE_TRG) DDL statement.
--#
--# Call Syntax  : SQL> @ddl_trace_trg
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000 long 5000;
set verify off;

Prompt
Prompt ##
Prompt ## USER_TRACE_TRG:
Prompt ##

select dbms_metadata.get_ddl('TRIGGER','USER_TRACE_TRG') as "DDL" 
from   dual;

Prompt
Prompt Note: use "create_trace_trg.sql" script to recreate trigger.
Prompt
