--#-----------------------------------------------------------------------------------
--# File Name    : invalid_objects.sql
--#
--# Description  : Shows info about invalid objects (count, types, etc).
--#
--# Call Syntax  : @invalid_objects
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Count of Invalid Objects:
Prompt ##

select count(*) "COUNT"
from   dba_objects
where  status <> 'VALID';

Prompt ##
Prompt ## Count by Schema:
Prompt ##

col owner for a20

select owner
       ,count(*)
from   dba_objects
where  status <> 'VALID'
group  by owner
order  by 2 desc;

Prompt ##
Prompt ## Count by Type:
Prompt ##

col object_type for a30

select object_type
       ,count(*)
from   dba_objects
where  status <> 'VALID'
group  by object_type
order  by 2 desc;

Prompt ##
Prompt ## Count by Schema/Type:
Prompt ##

select owner
       ,object_type
       ,count(*)
from   dba_objects
where  status <> 'VALID'
group  by owner,object_type
order  by 3 desc;

Prompt
Prompt Note: to recompile all invalid objects: SQL> exec utl_recomp.recomp_parallel(8);
Prompt
