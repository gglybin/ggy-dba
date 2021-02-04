--#-----------------------------------------------------------------------------------
--# File Name    : repl_param_check.sql
--#
--# Description  : Shows some of replication related parameters and its values.
--#
--# Call Syntax  : psql=# \i repl_param_check.sql
--#-----------------------------------------------------------------------------------

\echo ''
\echo '##'
\echo '## Replication parameters:'
\echo '##'
\echo ''

select name
       ,setting
       ,unit
       ,sourcefile
       ,pending_restart
from   pg_settings
where  name in ('wal_level','archive_mode','max_wal_senders','wal_keep_segments','listen_addresses','hot_standby','archive_command','synchronous_commit','synchronous_standby_names')
order  by name;

--
-- Note: - name, setting, unit - название и значение параметра,
--       - boot_val - значение по умолчанию,
--       - reset_val - если параметр был изменен во время сеанса, то командой RESET можно восстановить это значение,
--       - source - источник текущего значения параметра,
--       - pending_restart - значение изменено в файле конфигурации, но для применения требуется перезапуск сервера.
--
