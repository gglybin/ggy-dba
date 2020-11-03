--#-----------------------------------------------------------------------------------
--# File Name    : expire_pwd_check.sql
--#
--# Description  : Find users which passwords expire or will expire soon.
--#
--# Call Syntax  : SQL> @expire_pwd_check (days-before-expire)
--#
--# Example      : SQL> @expire_pwd_check 7   -- it will check if there are any users whose password will expired during next 7 days or expired already.
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

col username for a30
col account_status for a30
col expiry_date for a30

select username
       ,account_status
       ,to_char(expiry_date, 'HH24:MI:SS DD-MON-YYYY') expiry_date
from   dba_users
where  ((expiry_date - sysdate) <= to_number('&&1') or (expiry_date is null and account_status like 'EXPIRE%'));
-- and    oracle_maintained='N'; -- to hide oracle system user accounts

Prompt
Prompt Note: use "user_info.sql" script to get more detailed information about specific user.
Prompt
