--#-----------------------------------------------------------------------------------
--# File Name    : nls_check.sql
--#
--# Description  : Shows current NLS settings.
--#
--# Call Syntax  : @nls_check
--#-----------------------------------------------------------------------------------

set lines 4000 pages 1000;

Prompt
Prompt ##
Prompt ## NLS settings:
Prompt ##

col parameter for a30
col database  for a30
col instance  for a30
col session   for a30

select a.parameter
       ,a.value "DATABASE"
       ,b.value "INSTANCE"
       ,c.value "SESSION"
from   nls_database_parameters  a
       ,nls_instance_parameters b
       ,nls_session_parameters  c
where  a.parameter=b.parameter(+) and a.parameter=c.parameter(+)
order  by 1;

