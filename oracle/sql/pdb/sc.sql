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

select '-------------------------------------' ||chr(10)||'Connected to '||sys_context('userenv','con_name')||' container.'||chr(10)||'-------------------------------------'
from dual;

-- def _CONNECT_IDENTIFIER = &&1

set verify on;
set feedback on;
set heading on;
