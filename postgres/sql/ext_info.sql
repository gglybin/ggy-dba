--#-----------------------------------------------------------------------------------
--# File Name    : ext_info.sql
--#
--# Description  : Shows list of installed extensions.
--#
--# Call Syntax  : psql=# \i ext_info.sql
--#
--# References   : https://blog.dbi-services.com/listing-the-extensions-available-in-postgresql/
--#-----------------------------------------------------------------------------------

\echo ''
\echo '##'
\echo '## Parameter:'
\echo '##'
\echo ''

select name
       ,setting
       ,sourcefile
       ,applied
from   pg_file_settings
where  name='shared_preload_libraries'
and    applied='t';

\echo ''
\echo '##'
\echo '## List of installed extensions:'
\echo '##'
\echo ''

select e.extname as "Name"
       ,e.extversion as "Version"
       ,n.nspname as "Schema"
       ,c.description as "Description"
from   pg_catalog.pg_extension e
         left join pg_catalog.pg_namespace n on n.oid = e.extnamespace
           left join pg_catalog.pg_description c on c.objoid = e.oid and c.classoid = 'pg_catalog.pg_extension'::pg_catalog.regclass
order  by 1;

\echo ''
\echo 'Note 1: use "pg_available_extensions" to check available extensions.'
\echo ''
\echo 'Note 2: use "pg_ailable_extension_versions" to check dependencies between extensions.'
\echo ''
