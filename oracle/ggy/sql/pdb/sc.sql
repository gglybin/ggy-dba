--#-----------------------------------------------------------------------------------
--# File Name    : sc.sql
--#
--# Description  : Change current container at session level.
--#
--# Call Syntax  : SQL> @sc <PDB_NAME>
--#
--#                SQL> @sc CDB$ROOT
--#-----------------------------------------------------------------------------------

SET VERIFY OFF;

ALTER SESSION SET CONTAINER = &&1;
