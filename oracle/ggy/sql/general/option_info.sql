--#-----------------------------------------------------------------------------------
--# File Name    : option_info.sql
--#
--# Description  : Shows if given option is enabled or not.
--#
--# Call Syntax  : SQL> @option_info (option-full-name)
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

Prompt
Prompt ##
Prompt ## Option status:
Prompt ##

col parameter for a80
col value     for a15
 
select *
from   v$option
where  parameter='&&1';
