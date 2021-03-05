--#-----------------------------------------------------------------------------------
--# File Name    : role_objects.sql
--#
--# Description  : Shows count objects owned by role ordered by objects type.
--#
--# Call Syntax  : bash$ psql -d test_db -v role=\'test_usr\' -f role_objects.sql
--#-----------------------------------------------------------------------------------


select
        case
              when relkind = 'r' then 'Table'
              when relkind = 'i' then 'Index'
              when relkind = 'S' then 'Sequence'
              when relkind = 't' then 'TOAST table'
              when relkind = 'm' then 'Materialized view'
              when relkind = 'c' then 'Composite type'
              when relkind = 'f' then 'Foreign table'
              when relkind = 'p' then 'Partitioned table'
              when relkind = 'v' then 'View'
              else 'Unknown ...'
        end "Object Type",
        count(*)  as "Count"
from
        pg_class
where
        relowner=(select oid from pg_roles where rolname = :role)
group
        by relkind
order
        by 2 desc;
