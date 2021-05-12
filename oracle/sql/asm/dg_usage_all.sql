--#-----------------------------------------------------------------------------------
--# File Name     : dg_usage_all.sql
--#
--# Description   : Shows usage of all ASM diskgroups.
--#
--# Call Syntax   : @dg_usage_all
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

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
order  by 5 desc;

Prompt
Prompt Note: use "asmdu.sh" script to check usage from asmcmd console.
Prompt
