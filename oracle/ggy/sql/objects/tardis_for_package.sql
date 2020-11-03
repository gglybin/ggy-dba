--#-----------------------------------------------------------------------------------
--# File Name    : tardis_for_package.sql
--#
--# Description  : Script provides package/package body state as of provided time.
--#
--# Call Syntax  : SQL> @tardis_for_package (timestamp) (package-owner) (package-name)
--#
--#                SQL> @tardis_for_package "03-28-2019 23:55" HR EMP_MGMT
--#
--# References   : https://dba-notes.org/archives/1184/
--#                https://oracle-base.com/articles/10g/flashback-query-10g
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

Prompt
Prompt ##
Prompt ## Object info as of "&&1"
Prompt ##

col owner         for a20
col object_name   for a50
col object_type   for a30
col status        for a10
col created       for a20
col last_ddl_time for a20

select owner
       ,object_id
       ,object_name
       ,object_type
       ,status
       ,to_char(created, 'DD-MON-YY HH24:MI') "CREATED"
       ,to_char(last_ddl_time, 'DD-MON-YY HH24:MI') "LAST_DDL_TIME"
from   dba_objects as of timestamp to_date('&&1', 'mm.dd.yyyy hh24:mi')
where  owner='&&2'
and    object_name='&&3'
and    object_type like 'PACKAGE%'
order  by object_type;


set term off;

undefine pkg_spec_id
column   pkg_spec_id new_value pkg_spec_id

select object_id as pkg_spec_id
from   dba_objects as of timestamp to_date('&&1', 'mm.dd.yyyy hh24:mi')
where  owner='&&2'
and    object_name='&&3'
and    object_type='PACKAGE';

undefine pkg_body_id
column   pkg_body_id new_value pkg_body_id

select object_id as pkg_body_id
from   dba_objects as of timestamp to_date('&&1', 'mm.dd.yyyy hh24:mi')
where  owner='&&2'
and    object_name='&&3'
and    object_type='PACKAGE BODY';

set term on;

Prompt ##
Prompt ## "&&2"."&&3" SPEC:
Prompt ##

col line   for 99,999,999
col source for a90

select line
       ,source
from   source$ as of timestamp to_date('&&1', 'mm.dd.yyyy hh24:mi')
where  obj#=&&pkg_spec_id;

Prompt ##
Prompt ## "&&2"."&&3" BODY:
Prompt ##

col line   for 99,999,999
col source for a90

select line
       ,source
from   source$ as of timestamp to_date('&&1', 'mm.dd.yyyy hh24:mi')
where  obj#=&&pkg_body_id;

Prompt
Prompt Note: use "tardis_for_table.sql" script to try to get back unexpectedly removed data.
Prompt
