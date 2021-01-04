--#-----------------------------------------------------------------------------------
--# File Name    : pdb_info.sql
--#
--# Description  : Shows information about PDB's available in current CDB.
--#
--# Call Syntax  : SQL> @pdb_info
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

col name        for a20
col open_mode   for a20
col restricted  for a20

select
          con_id,
          name,
          open_mode,
          restricted,
          open_time,
          round((total_size / 1024 / 1024)) as "TOTAL_SIZE_MB",
          block_size
from
          v$pdbs
order by
          con_id;
