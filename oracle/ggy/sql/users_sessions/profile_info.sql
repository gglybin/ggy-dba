--#-----------------------------------------------------------------------------------
--# File Name    : profile_info.sql
--#
--# Description  : Shows information about profile.
--#
--# Call Syntax  : @profile_info (profile-name)
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

Prompt
Prompt ##
Prompt ## &&1 profile details:
Prompt ##

col profile for a30
col resource_name for a50
col resource_type for a20
col limit for a20
col common for a10
col inherited for a10
col implicit for a10

select *
from   dba_profiles
where  profile='&&1'
order  by resource_name;

Prompt ##
Prompt ## Count of users with &&1 profile assigned:
Prompt ##

col username for a30

select profile
       ,count(*) as "USER COUNT"
from   dba_users
where  profile='&&1'
group  by profile;
