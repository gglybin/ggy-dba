--#-----------------------------------------------------------------------------------
--# File Name    : check_patch.sql
--#
--# Description  : Checks if provided patch is installed.
--#
--# Call Syntax  : SQL> @check_patch (patch-number)
--#-----------------------------------------------------------------------------------

set long 1000000 pagesize 0;
set verify off;
set feedback off;

Prompt
Prompt ##
Prompt ## Checking patch &&1:
Prompt ##

select xmltransform(dbms_qopatch.is_patch_installed('&&1'), dbms_qopatch.get_opatch_xslt) from dual;

set feedback on;
set verify on;

Prompt
Prompt Note: use "db_patch_list.sql" script to get list of patches applied in database using datapatch.
Prompt
Prompt Note: use "oh_patch_list.sql" script to get list of patches applied on database ORACLE_HOME.
Prompt
