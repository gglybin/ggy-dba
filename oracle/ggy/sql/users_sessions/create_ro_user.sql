--#-----------------------------------------------------------------------------------
--# File Name    : create_RO_user.sql
--#
--# Description  : Script to create user with READ-ONLY grant to all objects in database (including dictionary).
--#
--# DB version   : >= 12.1
--#
--# Call Syntax  : @create_RO_user
--#-----------------------------------------------------------------------------------

set define '%'
set lines 1000 pages 1000
set verify off
set echo off
set feedback off
set heading off
set linesize 160
clear screen

whenever sqlerror exit sql.sqlcode rollback;

prompt
prompt *********** SCRIPT WILL CREATE USER WITH READ-ONLY ACCESS TO ALL OBJECTS IN DATABASE ***********
prompt

--
-- Get input values from user
--

prompt ========================== Input ==========================
prompt
accept ROUser         prompt "Enter user name [RO_USER]: "              default RO_USER
accept ROUserPassword prompt "Enter password [PassWord_123]: " hide     default PassWord_123
accept ROUserTbs      prompt "Enter default user tablespace [USERS]: "  default USERS
accept ROUserTmpTbs   prompt "Enter default user tablespace [TEMP]: "   default TEMP
accept ROUserProfile  prompt "Enter user profile [DEFAULT]: "           default DEFAULT

--
-- Check user input
--

prompt
prompt ========================== Pre-checks ======================
prompt

set serveroutput on

declare
   isExist varchar(1);
begin
   dbms_output.put_line('INFO:  Checking if %ROUser user doesn''t exist ...');
   select count(1) into isExist from dba_users where username='%ROUser';
   if isExist = 1 then
      raise_application_error(-20000,'ERROR: User with name %ROUser already exist.');
   else
      dbms_output.put_line('INFO:  %ROUser user  doesn''t exist.');
   end if;
   dbms_output.put_line('INFO:  Checking if %ROUserTbs tablespace exist ...');
   select count(1) into isExist from dba_tablespaces where tablespace_name='%ROUserTbs' and contents='PERMANENT';
   if isExist <> 1 then
      raise_application_error(-20000,'ERROR: Tablespace %ROUserTbs doesn''t exist.');
   else
      dbms_output.put_line('INFO:  %ROUserTbs tablespace exist.');
   end if;
   dbms_output.put_line('INFO:  Checking if %ROUserTmpTbs temp tablespace exist ...');
   select count(1) into isExist from dba_tablespaces where tablespace_name='%ROUserTmpTbs' and contents='TEMPORARY';
   if isExist <> 1 then
      raise_application_error(-20000,'ERROR: Temporary tablespace %ROUserTmpTbs doesn''t exist.');
   else
      dbms_output.put_line('INFO:  %ROUserTmpTbs tablespace exist.');
   end if;
   dbms_output.put_line('INFO:  Checking if %ROUserProfile profile exist ...');
   select count(1) into isExist from dba_profiles where profile='%ROUserProfile' and rownum <= 1;
   if isExist <> 1 then
      raise_application_error(-20000,'ERROR: Profile %ROUserProfile doesn''t exist.');
   else
      dbms_output.put_line('INFO:  Profile %ROUserProfile exist.');
   end if;
end;
/

--
-- Get confirmation from user before continue
--

prompt
prompt ========================== Confirmation =====================
prompt
prompt READ-ONLY User details:
prompt
prompt USERNAME         = %ROUser
prompt TABLESPACE       = %ROUserTbs
prompt TEMP_TABLESPACE  = %ROUserTmpTbs
prompt USER+PROFILE     = %ROUserProfile
prompt
prompt If this is correct, press ENTER to proceed.
prompt Otherwise press Ctrl+C to cancel script execution.
prompt 
prompt Note: make sure you have DBA privileges before continuing!

pause

prompt ========================== Start ============================
prompt

--
-- Create user
--

begin
   dbms_output.put_line('INFO:  Creating %ROUser user ...');
   execute immediate 'CREATE USER "%ROUser" identified by "%ROUserPassword" DEFAULT TABLESPACE "%ROUserTbs" TEMPORARY TABLESPACE "%ROUserTmpTbs" PROFILE "%ROUserProfile" ACCOUNT UNLOCK';
   dbms_output.put_line('INFO:  Created %ROUser user.'); 
exception
   when others then
      dbms_output.put_line(sqlerrm);
      raise_application_error(-20000,'ERROR: User creation failed.');  
end;
/ 

--
-- Assign connect and read-only grants
--

begin   
   dbms_output.put_line('INFO:  Assign CONNECT to %ROUser user.');
   execute immediate 'GRANT CONNECT TO %ROUser';
   dbms_output.put_line('INFO:  Assign READ ANY TABLE to %ROUser user.');
   execute immediate 'GRANT READ ANY TABLE TO %ROUser';
   dbms_output.put_line('INFO:  Assign SELECT ANY DICTIONARY to %ROUser user.');
   execute immediate 'GRANT SELECT ANY DICTIONARY TO %ROUser';
exception
   when others then
      dbms_output.put_line(sqlerrm);
      raise_application_error(-20000,'ERROR: Failed to assing grants.');
end;
/


set serveroutput off

prompt
prompt ========================== Done =============================
prompt
exit;
