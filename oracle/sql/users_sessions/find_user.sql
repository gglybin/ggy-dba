--#-----------------------------------------------------------------------------------
--# File Name    : find_user.sql
--#
--# Description  : Scripts tries to find if user(s) with provided name exist.
--#
--# Call Syntax  : @find_user (user-name)
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

col username              for a20
col account_status        for a20
col default_tablespace    for a20
col temporary_tablespace  for a20
col local_temp_tablespace for a22
col "CREATED"             for a18
col password_versions     for a18
col "LAST_PWD_CHANGE"     for a18
col "LAST_LOGIN"          for a18

select
       username
       ,user_id
       ,account_status
       ,default_tablespace
       ,temporary_tablespace
       ,local_temp_tablespace
       ,to_char(created, 'HH24:MI DD-MON-YY') as "CREATED"
       ,password_versions
       ,to_char(password_change_date, 'HH24:MI DD-MON-YY') as "LAST_PWD_CHANGE"
       ,to_char(last_login, 'HH24:MI DD-MON-YY') as "LAST_LOGIN"
from   dba_users
where  username like '&&1';

Prompt
Prompt Note: use "user_info.sql" script to get more detailed information about the user.
Prompt
