--#-----------------------------------------------------------------------------------
--# File Name    : find_object.sql
--#
--# Description  : Script tries to find if object(s) with provided name are exist.
--#
--# Call Syntax  : @find_object (part-of-object-name)
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

col owner         for a20
col object_name   for a70
col object_type   for a30
col status        for a10
col created       for a20
col last_ddl_time for a20

select owner
       ,object_name
       ,object_type
       ,status
       ,to_char(created, 'DD-MON-YY HH24:MI') "CREATED"
       ,to_char(last_ddl_time, 'DD-MON-YY HH24:MI') "LAST_DDL_TIME"
from   dba_objects 
where  object_name like upper('&&1') 
order  by owner, created desc, last_ddl_time desc, object_type;

Prompt
Prompt Note: user "table_info.sql" script to get more detailed information about the particular table.
Prompt
