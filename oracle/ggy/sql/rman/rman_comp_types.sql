--#-----------------------------------------------------------------------------------
--# File Name    : rman_comp_types.sql
--#
--# Description  : Shows available RMAN compression algorithms.
--#
--# Call Syntax  : SQL> @rman_comp_types
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## RMAN Compression Algorithms:
Prompt ##

col algorithm_name          for a20
col algorithm_description   for a70
col algorithm_compatibility for a30
col is_valid                for a15
col is_default              for a15
col requires_aco            for a15

select algorithm_name
       ,algorithm_description
       ,algorithm_compatibility
       ,is_valid
       ,is_default
       ,requires_aco
from   v$rman_compression_algorithm;

Prompt
Prompt Note: use "option_info.sql" script to check if "Advanced Compression" option enabled. 
Prompt
