--#-----------------------------------------------------------------------------------
--# File Name    : param_info.sql
--#
--# Description  : Shows information about given database parameter.
--#
--# Call Syntax  : @param_info (parameter-name)
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

Prompt
Prompt ##
Prompt ## Session level:
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
from   v$parameter
where  name='&&1';

Prompt ##
Prompt ## Instance level:
Prompt ##

select name
       ,value
       ,issys_modifiable
       ,ispdb_modifiable
       ,isses_modifiable
       ,description
from   v$system_parameter2
where  name='&&1';

Prompt
Prompt IMMEDIATE = We can change the parameter in fly database ie Dynamic
Prompt DEFERRED  = We can change the parameter in fly database, but this will effect after restart the database only
Prompt FALSE     = Compulsory we need to down the database ie Static
Prompt
