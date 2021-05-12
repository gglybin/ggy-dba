--#-----------------------------------------------------------------------------------
--# File Name     : disk_info_all.sql
--#
--# Description   : Shows information about all ASM disks.
--#
--# Call Syntax   : @disk_info_all
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Disks:
Prompt ##

col "DG_NAME"    for a15
col "MOUNT_DATE" for a20
col name         for a15
col "FAIL_GROUP" for a15
col path         for a50
col "STATUS"     for a15
col state        for a15

select g.name "DG_NAME"
       ,d.failgroup "FAIL_GROUP"
       ,d.disk_number "DISK_NUMBER"
       ,to_char(d.mount_date,'DD-MON-YYYY HH24:MI:SS') "MOUNT_DATE"
       ,d.name disk_name
       ,d.path path
       ,d.total_mb total_mb
       ,d.free_mb free_mb
       ,(d.total_mb - d.free_mb) "USED_MB"
       ,round((1 - (d.free_mb / d.total_mb))*100, 1) "USED_%"
       ,d.mode_status "STATUS"
       ,d.state state
from   v$asm_disk d,
       v$asm_diskgroup g
where  g.group_number=d.group_number
order  by g.name, d.name;

Prompt
Prompt Note: use "disk_info.sql" script to get more detailed information about particular disk.
Prompt
