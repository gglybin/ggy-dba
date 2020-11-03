--#-----------------------------------------------------------------------------------
--# File Name     : disk_info.sql
--#
--# Description   : Shows information about ASM disk.
--#
--# Call Syntax   : @disk_info (disk-name)
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;
set linesize 120
set head off

select
'======================= Info  ============================',
'DISK_GROUP ..............................................: '||g.name,
'FAIL_GROUP ..............................................: '||d.failgroup,
'FAIL_GROUP_TYPE .........................................: '||d.failgroup_type,
'DISK_CREATE_DATE ........................................: '||to_char(d.create_date,'DD-MON-YYYY HH24:MI:SS'),
'DISK_MOUNT_DATE .........................................: '||to_char(d.mount_date,'DD-MON-YYYY HH24:MI:SS'),
'DISK_NUMBER .............................................: '||d.disk_number,
'DISK_NAME ...............................................: '||d.name,
'PATH ..................................................... '||d.path,
'TOTAL_SIZE ..............................................: '||d.total_mb||' MB',
'FREE_SPACE ..............................................: '||d.free_mb||' MB',
'USED_SPACE ..............................................: '||(d.total_mb - d.free_mb)||' MB',
'USED_PCT ................................................: '||round((1 - (d.free_mb / d.total_mb))*100, 1)||'%',
'STATUS ..................................................: '||d.mode_status,
'STATE ...................................................: '||d.state,
'VOTING_FILE .............................................: '||d.voting_file,
'LIBRARY .................................................: '||d.library
from   v$asm_disk d,
       v$asm_diskgroup g
where  d.group_number=g.group_number
and    d.name='&&1'
order  by disk_number;

set head on;
