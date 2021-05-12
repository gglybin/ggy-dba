--#-----------------------------------------------------------------------------------
--# File Name    : patch_list_formatted.sql
--#
--# Description  : Shows patches installed in database and ORACLE_HOME.
--#
--# Call Syntax  : SQL> @patch_list_formatted
--#
--# References   : https://blog.pythian.com/oracle-database-12c-patching-dbms_qopatch-opatch_xml_inv-and-datapatch/
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## List of all patches:
Prompt ##

with a as (select dbms_qopatch.get_opatch_lsinventory patch_output from dual)
select x.patch_id
       ,x.patch_uid
       ,x.description
from a,
     xmltable('InventoryInstance/patches/*'
     passing a.patch_output
     columns
       patch_id number path 'patchID',
       patch_uid number path 'uniquePatchID',
       description varchar2(80) path 'patchDescription'
       ) x;

Prompt ##
Prompt ## Patches applied to both the $OH and the DB (i.e. datapatch was run):
Prompt ##

with a as (select dbms_qopatch.get_opatch_lsinventory patch_output from dual)
select x.patch_id
       ,x.patch_uid
       ,x.rollbackable
       ,s.status
       ,x.description
from a,
     xmltable('InventoryInstance/patches/*'
     passing a.patch_output
     columns
       patch_id number path 'patchID',
       patch_uid number path 'uniquePatchID',
       description varchar2(80) path 'patchDescription',
       rollbackable varchar2(8) path 'rollbackable'
      ) x,
      dba_registry_sqlpatch s
where x.patch_id = s.patch_id
and   x.patch_uid = s.patch_uid;

Prompt ##
Prompt ## Patches installed to $OH only:
Prompt ##

with a as (select dbms_qopatch.get_opatch_lsinventory patch_output from dual)
select x.patch_id
       ,x.patch_uid
       ,x.description
from a,
     xmltable('InventoryInstance/patches/*'
     passing a.patch_output
     columns
       patch_id number path 'patchID',
       patch_uid number path 'uniquePatchID',
       description varchar2(80) path 'patchDescription'
       ) x
minus
select s.patch_id
       ,s.patch_uid
       ,s.description
from   dba_registry_sqlpatch s;

Prompt
Prompt ===== Additional scripts =====
Prompt
Prompt 1) db_patch_list.sql : shows patches applied to database (i.e. datapatch was run);
Prompt 2) oh_patch_list.sql : shows all patches applied to ORACLE_HOME with additional details.
Prompt 3) check_patch.sql   : checks if provided patch is installed on the system.
Prompt
