--#-----------------------------------------------------------------------------------
--# File Name    : oh_patch_list.sql
--#
--# Description  : Shows info about patches applied to database ORACLE_HOME.
--#
--# Call Syntax  : SQL> @oh_patch_list
--#-----------------------------------------------------------------------------------

set long 1000000 pagesize 0;
set termout off;
set feedback off;
set serveroutput on;
spool oh_patch_list.out;

Prompt ##
Prompt ## Info:
Prompt ##

select xmltransform(dbms_qopatch.get_opatch_install_info, dbms_qopatch.get_opatch_xslt) from dual;

Prompt ##
Prompt ## Count of patches:
Prompt ##
Prompt

select xmltransform(dbms_qopatch.get_opatch_count, dbms_qopatch.get_opatch_xslt) from dual;

Prompt
Prompt ##
Prompt ## List of patches:
Prompt ##

/***************
-- opatch lsinventory -detail
select xmltransform(dbms_qopatch.get_opatch_lsinventory, dbms_qopatch.get_opatch_xslt) from dual; 
***************/

select xmltransform(dbms_qopatch.get_opatch_list, dbms_qopatch.get_opatch_xslt) from dual;

spool off;

set termout on;

begin
  dbms_output.put_line(chr(1));
  dbms_output.put_line('Output: oh_patch_list.out');
end;
/

set serveroutput off;
set feedback on;

Prompt
Prompt Note: use "db_patch_list.sql" script to get list of patches applied in database using datapatch.
Prompt
