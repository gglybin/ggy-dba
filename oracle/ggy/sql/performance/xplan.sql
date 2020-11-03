--#-----------------------------------------------------------------------------------
--# File Name    : xplan.sql
--#
--# Description  : Show query execution plan using SQL_ID provided.
--#
--# Call Syntax  : 
--#                 Get all query plans from CACHE:
--#                 -------------------------------
--#                 SQL> @xplan (sql-id) (child-number)                    
--#
--#                 Get all query plans from AWR:
--#                 -------------------------------
--#                 SQL> @xplan (sql-id)
--#
--#                 Get specific plan from AWR:
--#                 -------------------------------
--#                 SQL> @xplan (sql-id) (plan-hash-value)
--# 
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

set linesize 250 pagesize 0 trims on tab off long 1000000;

Prompt
Prompt ##
Prompt ## Execution Plan for &&1:
Prompt ##
Prompt

-----------------------------
-- From Cache (v$sql_plan) --
-----------------------------

select *
from   table(dbms_xplan.display_cursor('&&1','&&2','ALL +OUTLINE'));

/*
------------------------------------------------
-- From AWR - show all plans for given sql_id --
------------------------------------------------

select * 
from   table(dbms_xplan.display_awr('&&1', null, null, 'ALL +OUTLINE'));
*/

/*
------------------------------------------------------------------------------
-- From AWR - show particular (using plan_hash_value) plan for given sql_id --
------------------------------------------------------------------------------

select * 
from   table(dbms_xplan.display_awr('&&1', '&&2', null, 'ALL +OUTLINE'));
*/
