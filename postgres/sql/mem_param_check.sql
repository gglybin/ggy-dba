--#-----------------------------------------------------------------------------------
--# File Name    : mem_param_check.sql
--#
--# Description  : Shows memory related parameters and its values.
--#
--# Call Syntax  : psql=# \i mem_param_check.sql
--#
--# References   : https://www.enterprisedb.com/postgres-tutorials/how-tune-postgresql-memory
--#                https://edu.postgrespro.ru/dba1/dba1_03_tools_configuration.html
--#-----------------------------------------------------------------------------------

\echo ''
\echo '##'
\echo '## From config file:'
\echo '##'
\echo ''

select name
       ,setting
       ,sourcefile
       ,applied
from   pg_file_settings
where  name in ('shared_buffers','work_mem','maintenance_work_mem','effective_cache_size','wal_buffers')
and    applied='t'
order  by name;

--
-- Note: Представление pg_file_settings показывает лишь содержимое файлов конфигурации, реальные значения параметров могут отличаться.
--

\echo ''
\echo '##'
\echo '## From instance:'
\echo '##'
\echo ''

select name
       ,setting
       ,unit
       ,sourcefile
       ,pending_restart
from   pg_settings
where  name in ('shared_buffers','work_mem','maintenance_work_mem','effective_cache_size','wal_buffers')
order  by name;

--
-- Note: - name, setting, unit - название и значение параметра,
--       - boot_val - значение по умолчанию,
--       - reset_val - если параметр был изменен во время сеанса, то командой RESET можно восстановить это значение,
--       - source - источник текущего значения параметра,
--       - pending_restart - значение изменено в файле конфигурации, но для применения требуется перезапуск сервера.
--
