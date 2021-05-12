--#-----------------------------------------------------------------------------------
--# File Name              : get_ddl.sql
--#
--# Description            : Script to get DDL statement for object/user.
--#
--# Call Syntax            : SQL> @get_ddl
--#-----------------------------------------------------------------------------------

set define '%'
set lines 1000 pages 1000
set long 4444
set verify off
set echo off
set feedback off
set heading off
clear screen

prompt ********** LIST OF SUPPORTED/TESTED OBJECT TYPES **********
prompt
prompt -> USER
prompt -> TABLE
prompt -> VIEW
prompt -> MATERIALIZED_VIEW
prompt -> TRIGGER
prompt -> DB_LINK
prompt -> SYNONYM
prompt -> INDEX
prompt -> DIRECTORY
prompt -> PROFILE
prompt -> ROLE 
prompt -> CONSTRAINT
prompt -> SEQUENCE
prompt -> TABLESPACE
prompt

--
-- Get input values from user
--

prompt ========================== Input ==========================
prompt
prompt Note: if you want to get USER, DIRECTORY, PROFILE, ROLE or TABLESPACE  DDL - provide below parameters 
prompt
prompt ObjectType = OBJECT_TYPE (USER, DIRECTORY, PROFILE, ROLE or TABLESPACE)
prompt ObjectName = USER_NAME / OBJECT_NAME
prompt Owner      = <empty>
prompt 

accept ObjectType   prompt "Enter object TYPE [TABLE]: " default TABLE
accept ObjectName   prompt "Enter object NAME [DUAL]: "  default DUAL
accept Owner        prompt "Enter object OWNER [SYS]: "  default SYS

--
-- Get object DDL
--

prompt
prompt ========================== DDL =============================

select
case
  when '%ObjectType'='USER' or '%ObjectType'='DIRECTORY' or '%ObjectType'='PROFILE' or '%ObjectType'='ROLE' or '%ObjectType'='TABLESPACE'
    then (select dbms_metadata.get_ddl('%ObjectType','%ObjectName') DDL from dual)
  else (select dbms_metadata.get_ddl('%ObjectType','%ObjectName','%Owner') DDL from dual)
end
from dual;

prompt ============================================================
prompt
exit;
