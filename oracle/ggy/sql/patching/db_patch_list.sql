--#-----------------------------------------------------------------------------------
--# File Name    : db_patch_list.sql
--#
--# Description  : Shows info about patches applied in database using datapatch tool.
--#
--# Call Syntax  : SQL> @db_patch_list
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Patches installed in database:
Prompt ##

col patch_type    for a20
col action        for a20
col status        for a20
col "ACTION_TIME" for a20
col description   for a60

select patch_id
       ,patch_type
       ,action
       ,status
       ,to_char(action_time, 'DD-MON-YY HH24:MI:SS') as "ACTION_TIME"
       ,description
from   dba_registry_sqlpatch
order  by action_time;

/***************
exec dbms_qopatch.get_sqlpatch_status;
***************/

Prompt
Prompt Note: use "oh_patch_list.sql" script to get list of patches applied on database ORACLE_HOME.
Prompt
