--#-----------------------------------------------------------------------------------
--# File Name    : sc.sql
--#
--# Description  : Change current container at session level.
--#
--# Call Syntax  : SQL> @sc <PDB_NAME>
--#
--#                SQL> @sc CDB$ROOT
--#-----------------------------------------------------------------------------------

set verify off;
set feedback off;
set heading off;

alter session set container = &&1;

select 'Connected to '||sys_context('userenv','con_name')||' container.' from dual;

set verify on;
set feedback on;
set heading on;
