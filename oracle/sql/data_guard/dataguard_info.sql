--#-----------------------------------------------------------------------------------
--# File Name     : dataguard_info.sql
--#
--# Description   : Check dataguard settings.
--#
--# Call Syntax   : SQL> @dataguard_info
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## DB Info:
Prompt ##

col "CREATED"         for a20
col "RESETLOGS_DATE"  for a20
col name              for a15
col db_unique_name    for a15
col open_mode         for a20
col database_role     for a18
col protection_mode   for a25
col protection_level  for a25
col log_mode          for a15
col controlfile_type  for a20
col dataguard_broker  for a18

select to_char(created, 'DD-MON-YY HH24:MI') "CREATED"
       ,to_char(resetlogs_time, 'DD-MON-YY HH24:MI') "RESETLOGS_DATE"
       ,name
       ,db_unique_name
       ,open_mode
       ,database_role
       ,protection_mode
       ,protection_level
       ,log_mode
       ,controlfile_type
       ,dataguard_broker
from   v$database;

Prompt ##
Prompt ## Destinations:
Prompt ##

col dest_name       for a20
col status          for a10
col type            for a10
col database_mode   for a20
col recovery_mode   for a25
col protection_mode for a20
col destination     for a70

select dest_name
       ,status
       ,type
       ,database_mode
       ,recovery_mode
       ,protection_mode
       ,destination
from   v$archive_dest_status
where  destination is not null
order  by dest_name;

Prompt ##
Prompt ## Parameters:
Prompt ##

col name             for a30
col value            for a150

select name
       ,value
from   v$system_parameter2
where  name in ('log_archive_config','fal_server','fal_client','standby_file_management','log_archive_format')
       or name in (select lower(dest_name) from v$archive_dest_status where destination is not null)
union  all
select name
       ,value
from   v$system_parameter2
where  name in (select substr(name,1,17) || 'state' || substr(name,17)
                from   v$system_parameter2
                where  name in (select lower(dest_name) from v$archive_dest_status where destination is not null))
order  by name;
