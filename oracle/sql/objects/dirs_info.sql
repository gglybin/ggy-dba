--#-----------------------------------------------------------------------------------
--# File Name    : dirs_info.sql
--#
--# Description  : Shows info about all database directories.
--#
--# Call Syntax  : @dirs_info
--#-----------------------------------------------------------------------------------

set lines 4000 pages 1000;

Prompt
Prompt ##
Prompt ## Database directories:
Prompt ##

col owner          for a10
col directory_name for a30
col directory_path for a75

select owner
       ,directory_name
       ,directory_path
from   dba_directories
order  by owner;
