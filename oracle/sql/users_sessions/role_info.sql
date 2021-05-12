--#-----------------------------------------------------------------------------------
--# File Name    : role_info.sql
--#
--# Description  : Shows information about role.
--#
--# Call Syntax  : @role_info (role-name)
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

Prompt
Prompt ##
Prompt ## General:
Prompt ##

col role                for a30
col password_required   for a20
col authentication_type for a15
col common              for a10
col oracle_maintained   for a20
col inherited           for a10
col implicit            for a10
col external_name       for a15

select *
from   dba_roles 
where  role='&&1';

Prompt ##
Prompt ## Roles assigned to &&1 role:
Prompt ##

col granted_role for a30
col admin_option for a20

select * 
from   role_role_privs 
where  role='&&1';

Prompt ##
Prompt ## Grants assigned directly to role:
Prompt ##

col privilege for a30

select *
from   role_sys_privs
where  role='&&1';

Prompt ##
Prompt ## Table grants assigned directly to role:
Prompt ##

col owner       for a20
col table_name  for a40
col column_name for a40
col grantable   for a20

select *
from   role_tab_privs
where  role='&&1';
