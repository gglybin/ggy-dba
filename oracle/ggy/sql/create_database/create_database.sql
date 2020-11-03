--#---------------------------------------------------------------------------------------------
--# File Name    : create_database.sql
--#
--# Description  : Short script/template for database creation.
--#
--# Call Syntax  : SQL> @create_database
--#---------------------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;
set echo off;
set feedback off;
set linesize 150;
clear screen;

whenever sqlerror exit;

--
-- Get input values from user
--

prompt ========================== Input ============================
prompt
accept logfile     prompt "Enter script log file [/home/oracle/create_database.log]: " default /home/oracle/create_database.log
accept syspwd      prompt "Enter SYS user password: " hide default sys123
accept systempwd   prompt "Enter SYSTEM user password: " hide default system123
accept datadest    prompt "Enter Data/Temp Files location path: "
accept redodest1   prompt "Enter Redo Logs location path #1: "
accept redodest2   prompt "Enter Redo Logs location path #2: "
accept charset     prompt "Enter database character set [AL32UTF8]: " default AL32UTF8
accept nlscharset  prompt "Enter database national character set [AL16UTF16]: " default AL16UTF16

undefine dbname
column dbname new_value dbname
set termout off;
select value as dbname from v$system_parameter2 where name='db_name';
set termout on;

spool &logfile

prompt
prompt ========================== Confirmation =====================
prompt
prompt Going to create database with below parameters:
prompt
prompt Database name                = &dbname
prompt Data/Temp files location     = &datadest
prompt Redo Log files location #1   = &redodest1
prompt Redo Log files location #2   = &redodest2
prompt Character set                = &charset
prompt NLS Character set            = &nlscharset
prompt
prompt If this is correct, press ENTER to proceed.
prompt Otherwise press Ctrl+C to cancel script execution.

pause

--
-- Run CREATE DATABASE
--

prompt ========================== Start ============================

set heading off;
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Running CREATE DATABASE statement now ...' from dual;

CREATE DATABASE &dbname
USER SYS IDENTIFIED BY "&syspwd" USER SYSTEM IDENTIFIED BY "&systempwd"
LOGFILE
  GROUP 1 ('&redodest1/redo01a.log','&redodest2/redo01b.log') SIZE 1024M BLOCKSIZE 512,
  GROUP 2 ('&redodest1/redo02a.log','&redodest2/redo02b.log') SIZE 1024M BLOCKSIZE 512,
  GROUP 3 ('&redodest1/redo03a.log','&redodest2/redo03b.log') SIZE 1024M BLOCKSIZE 512
MAXLOGFILES 32
MAXLOGMEMBERS 3
MAXLOGHISTORY 1460
MAXDATAFILES 2048
MAXINSTANCES 8
CHARACTER SET &charset 
NATIONAL CHARACTER SET &nlscharset 
EXTENT MANAGEMENT LOCAL
DATAFILE
  '&datadest/system01.dbf' SIZE 1024M REUSE AUTOEXTEND ON NEXT 65536K MAXSIZE 32767M
SYSAUX DATAFILE
  '&datadest/sysaux01.dbf' SIZE 1024M REUSE AUTOEXTEND ON NEXT 65536K MAXSIZE 32767M
DEFAULT TABLESPACE USERS DATAFILE
  '&datadest/users01.dbf' SIZE 1024M REUSE AUTOEXTEND ON NEXT 65536K MAXSIZE 32767M
UNDO TABLESPACE UNDOTBS1 DATAFILE 
  '&datadest/undotbs01.dbf' SIZE 2048M REUSE
DEFAULT TEMPORARY TABLESPACE TEMP TEMPFILE 
  '&datadest/temp01.dbf' SIZE 2048M REUSE;

select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Database &dbname has been created.' from dual;

set heading on;

whenever sqlerror continue;

--
-- Install mandatory components
--

  --
  -- catalog.sql
  --

set heading off;
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Running catalog.sql script now ...' from dual;
set heading on;
prompt
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><><><><><><><> CATALOG <><><><><><><><><><><><><>
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><><> Oracle Database Catalog Views <><><><><><><>
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt
@?/rdbms/admin/catalog.sql
set echo off;
set feedback off;
set linesize 150;
set heading off;
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Completed catalog.sql script execution.' from dual;
set heading on;

  --
  -- catproc.sql
  --

set heading off;
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Running catproc.sql script now ...' from dual;
set heading on;
prompt
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><><><><><><><> CATPROC <><><><><><><><><><><><><>
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><> Oracle Database Packages and Types <><><><><><
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt
@?/rdbms/admin/catproc.sql
set echo off;
set feedback off;
set linesize 150;
set heading off;
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Completed catproc.sql script execution.' from dual;
set heading on;

  --
  -- pupbld.sql
  --

set heading off;
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Running pupbld.sql script now ...' from dual;
set heading on;
prompt
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><><><><><><><> SQLPLUS <><><><><><><><><><><><><>
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><> Install the SQL*Plus PRODUCT_USER_PROFILE tables <><><
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt
@?/sqlplus/admin/pupbld.sql
set echo off;
set feedback off;
set linesize 150;
set heading off;
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Completed pupbld.sql script execution.' from dual;
set heading on;

  --
  -- SQL Plus HELP Install
  --

/***************
undefine oracle_home
column oracle_home new_value oracle_home
set termout off;
select sys_context('USERENV','ORACLE_HOME') as oracle_home from dual;
set termout on;
set heading off;
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Running SQL Plus HELP installation scripts now ...' from dual;
set heading on;
prompt
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><><><><><><> SQLPLUS HELP <><><><><><><><><><><><
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt
@?/sqlplus/admin/help/helpbld.sql "&oracle_home/sqlplus/admin/help" "helpus.sql"
set echo off;
set feedback off;
set linesize 150;
set heading off;
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Completed SQL Plus HELP installation.' from dual;
set heading on;
***************/

--
-- Recompile invalid objects and components validation procedure
--

set heading off;
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Recompiling invalid objects now ...' from dual;
set heading on;
prompt
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><> OBJECTS / COMPONENETS RECOMPILATION <><><><><>
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt
@?/rdbms/admin/utlrp.sql
set echo off;
set feedback off;
set linesize 150;
set heading off;
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Completed objects recompilation.' from dual;
set heading on;

--
-- Install additional/optional components
--

  --
  -- Java Install scripts
  --

set heading off;
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Running Java installation scripts now ...' from dual;
set heading on;
prompt
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><><><><> JAVAVM / CATJAVA / XML <><><><><><><><><
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><><><> JServer JAVA Virtual Machine <><><><><><><
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><><><> Oracle Database Java Packages <><><><><><>
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><><><><><><> Oracle XDK <><><><><><><><><><><><><
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt
@?/javavm/install/initjvm.sql
@?/xdk/admin/initxml.sql
@?/xdk/admin/xmlja.sql
@?/rdbms/admin/catjava.sql
@?/rdbms/admin/catxdbj.sql
set echo off;
set feedback off;
set linesize 150;
set heading off;
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Java installation completed.' from dual;
set heading on;

  --
  -- Oracle Text (CONTEXT) Install scripts
  --

set heading off;
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Running Oracle Text installation scripts now ...' from dual;
set heading on;
prompt
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><><><><><><><> CONTEXT <><><><><><><><><><><><><>
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><><><><><><> Oracle Text <><><><><><><><><><><><>
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt
@?/ctx/admin/catctx.sql change_on_install SYSAUX TEMP LOCK
@?/ctx/admin/defaults/dr0defin.sql "AMERICAN"
--@?/ctx/admin/defaults/dr0defin.sql "RUSSIAN"
@?/rdbms/admin/dbmsxdbt.sql
set echo off;
set feedback off;
set linesize 150;
set heading off;
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Completed Oracle Text installation.' from dual;
set heading on;

  --
  -- Oracle Multimedia (ORDIM) Install scripts
  --

set heading off;
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Running Oracle Multimedia installation scripts now ...' from dual;
set heading on;
prompt
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><><><><><><><><> ORDIM <><><><><><><><><><><><><>
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><><><><><> Oracle Multimedia <><><><><><><><><><>
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt
@?/ord/admin/ordinst.sql SYSAUX SYSAUX
@?/ord/im/admin/iminst.sql
set echo off;
set feedback off;
set linesize 150;
set heading off;
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Completed Oracle Multimedia installation.' from dual;
set heading on;

  --
  -- Oracle OLAP (APS/XOQ) Installation scripts
  --

set heading off;
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Running Oracle OLAP (APS/XOQ) installation scripts now ...' from dual;
set heading on;
prompt
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><><><><><><> APS / XOQ <><><><><><><><><><><><><>
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><><><><> OLAP Analytic Workspace <><><><><><><><>
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><><><><><> Oracle OLAP API <><><><><><><><><><><>
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt
@?/olap/admin/olap.sql SYSAUX TEMP
set echo off;
set feedback off;
set linesize 150;
set heading off;
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Completed Oracle OLAP installation.' from dual;
set heading on;

  --
  -- Spatial (SDO) Installation scripts
  --

set heading off;
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Running Spatial (SDO) installation scripts now ...' from dual;
set heading on;
prompt
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><><><><><><><><> SDO <><><><><><><><><><><><><><>
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><><><><><><><> Spatial <><><><><><><><><><><><><>
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt
@?/md/admin/mdinst.sql
set echo off;
set feedback off;
set linesize 150;
set heading off;
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Completed Spatial (SDO) installation.' from dual;
set heading on;

  --
  -- Oracle Label Security Installation scripts
  --

set heading off;
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Running Label Security installation scripts now ...' from dual;
set heading on;
prompt
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><><><><><><><><> OLS <><><><><><><><><><><><><><>
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><><><><><> Oracle Label Security <><><><><><><><>
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt
@?/rdbms/admin/catols.sql
set echo off;
set feedback off;
set linesize 150;
set heading off;
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Completed Label Security installation.' from dual;
set heading on;

  --
  -- Oracle Database Vault Installation scripts
  --

set heading off;
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Running Database Vault installation sctipts now ...' from dual;
set heading on;
prompt
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><><><><><><><><><> DV <><><><><><><><><><><><><><
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><><><><><> Oracle Database Vault <><><><><><><><>
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt
@?/rdbms/admin/catmac.sql SYSAUX TEMP &syspwd
set echo off;
set feedback off;
set linesize 150;
set heading off;
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Completed Database Vault installation.' from dual;
set heading on;

  --
  -- Oracle Workspace Manager Installation scripts
  --

set heading off;
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Running Workspace Manager installation scripts now ...' from dual;
set heading on;
prompt
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><><><><><><><><> OWM <><><><><><><><><><><><><><>
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><><><><> Oracle Workspace Manager <><><><><><><><
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt
@?/rdbms/admin/owminst.plb
set echo off;
set feedback off;
set linesize 150;
set heading off;
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Completed Workspace Manager installation.' from dual;
set heading on;

--
-- Restart database instance
--

set heading off;
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Restarting database instance now ...' from dual;
set heading on;
prompt
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><><><><><> DATABASE RESTART <><><><><><><><><><><
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt
shutdown immediate;
startup;
set heading off;
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Database instance restart completed.' from dual;
set heading on;

--
-- Recompile invalid objects and components validation procedure
--

set heading off;
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Recompiling invalid objects now ...' from dual;
set heading on;
prompt
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt <><><><><><><> OBJECTS / COMPONENETS RECOMPILATION <><><><><>
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
prompt
@?/rdbms/admin/utlrp.sql
set echo off;
set feedback off;
set linesize 150;
set heading off;
prompt <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
select '|'||to_char(sysdate, 'MMDDYYYY_HH24:MI:SS')||'| INFO: Completed objects recompilation.' from dual;
set heading on;

prompt
prompt ========================== Done =============================
spool off;
exit;
