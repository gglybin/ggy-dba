--#-----------------------------------------------------------------------------------
--# File Name              : data_tops.sql
--#
--# Description            : Shows location of all database files and its count.
--#
--# Call Syntax            : SQL> @data_tops
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

col     path format a100
break   on   report
compute sum  label 'Total' of files_count on report

select 
       substr(name, 1, instr(name, '/', -1)) path
       ,count(*) files_count
from
     (
       select name from v$datafile union all
       select name from v$tempfile union all
       select name from v$controlfile union all
       select member name from v$logfile
     ) 
group by substr(name, 1, instr(name, '/', -1)) 
order by 1;
