--#-----------------------------------------------------------------------------------
--# File Name    : comp_info.sql
--#
--# Description  : Shows information about database components.
--#
--# Call Syntax  : @comp_info
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Components summary 
Prompt ##

col modified     for a40
col comp_id      for a10
col comp_name    for a50
col version      for a20
col version_full for a20
col status       for a20

select to_timestamp(modified,'DD-MON-YYYY HH24:MI:SS') modified
       ,comp_id
       ,comp_name
       ,version
       ,version_full
       ,status 
from   dba_registry
order by modified;
