--#-----------------------------------------------------------------------------------
--# File Name    : db_links_info.sql
--#
--# Description  : Shows info about all database links.
--#
--# Call Syntax  : @db_links_info
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Database Links:
Prompt ##

col owner    for a10
col db_link  for a30
col username for a10
col host     for a75
col created  for a15
col valid    for a10

select owner
       ,db_link
       ,username
       ,host
       ,to_char(created, 'HH24:MI DD-MON-YY') as "Created"
       ,valid
from   dba_db_links
order  by created desc;
