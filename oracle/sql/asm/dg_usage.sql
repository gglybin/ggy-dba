--#-----------------------------------------------------------------------------------
--# File Name     : dg_usage.sql
--#
--# Description   : Shows information about ASM diskgroup (usage, disks).
--#
--# Call Syntax   : @dg_usage (diskgroup-name)
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

Prompt
Prompt ##
Prompt ## Usage:
Prompt ##

col name          for a15
col state         for a15
col type          for a15
col compatibility for a15
col voting_files  for a15
col group_number  for a15

select group_number dg_number
       ,name dg_name
       ,total_mb total_mb
       ,free_mb free_mb
       ,(total_mb - free_mb) used_mb
       ,round((1- (free_mb / total_mb))*100, 1) "USED_%"
       ,state state
       ,type type
       ,compatibility,
       voting_files
from   v$asm_diskgroup
where  name='&&1';

Prompt ##
Prompt ## Disks:
Prompt ##

col "MOUNT_DATE" for a20
col name         for a15
col "FAIL_GROUP" for a15
col path         for a50
col "STATUS"     for a15
col state        for a15

select disk_number "DISK_NUMBER"
       ,to_char(mount_date,'DD-MON-YYYY HH24:MI:SS') "MOUNT_DATE"
       ,name disk_name
       ,failgroup "FAIL_GROUP"
       ,path path
       ,total_mb total_mb
       ,free_mb free_mb
       ,(total_mb - free_mb) "USED_MB"
       ,round((1- (free_mb / total_mb))*100, 1) "USED_%"
       ,mode_status "STATUS"
       ,state state
from   v$asm_disk
where  group_number=(select group_number from v$asm_diskgroup where name='&&1')
order  by disk_number;

Prompt
Prompt Note: use "asmdu.sh" script to check usage from asmcmd console.
Prompt
