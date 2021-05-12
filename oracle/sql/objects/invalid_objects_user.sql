--#-----------------------------------------------------------------------------------
--# File Name    : invalid_objects_user.sql
--#
--# Description  : Shows info about invalid objects for given user.
--#
--# Call Syntax  : SQL> @invalid_objects_user (user-name)
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

Prompt
Prompt ##
Prompt ## Count of Invalid Objects:
Prompt ##

select count(*) "COUNT"
from   dba_objects
where  owner='&&1'  
and    status <> 'VALID';

Prompt ##
Prompt ## Count by Type:
Prompt ##

col object_type for a30

select object_type
       ,count(*) "COUNT"
from   dba_objects
where  owner='&&1'
and    status <> 'VALID'
group  by object_type
order  by 2 desc;

Prompt ##
Prompt ## List of Invalid Objects:
Prompt ##

col owner         for a30
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
where  owner='&&1'
and    status<>'VALID';

Prompt
Prompt Note: to recompile all invalid objects: SQL> exec utl_recomp.recomp_parallel(8);
Prompt
