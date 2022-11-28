FROM zabbix/zabbix-agent2:ubuntu-5.2-latest

USER root

RUN export DEBIAN_FRONTEND=noninteractive && \
  apt-get update && \
  apt-get -y install iputils-ping fping dnsutils telnet && \
  cd /usr/sbin; ln -s /usr/bin/fping && \
  chown root:zabbix /usr/bin/fping && \
  chmod u+s /usr/bin/fping && \
  mkdir -p /etc/zabbix/zabbix_agentd.d/query && \
  sed -i 's/# Plugins.Postgres.CustomQueriesPath=/Plugins.Postgres.CustomQueriesPath=\/etc\/zabbix\/zabbix_agentd.d\/query/' /etc/zabbix/zabbix_agent2.conf && \
  echo "SELECT '<TABLE><TR><TH>test</TH></TR><TR><TD>тест</TD></TR></TABLE>';" > /etc/zabbix/zabbix_agentd.d/query/test.sql && \
  echo 'SELECT COUNT(*) FROM pg_ls_waldir() WHERE name ~ '"'"'^[0-9A-F]{24}$'"'"';' > /etc/zabbix/zabbix_agentd.d/query/walcount.sql && \
  echo 'SELECT COUNT(*) FROM pg_replication_slots;' > /etc/zabbix/zabbix_agentd.d/query/rslot.sql && \
  echo "SELECT COUNT(*) FROM pg_stat_activity WHERE (backend_xmin IS NOT NULL OR backend_xid IS NOT NULL) AND (current_timestamp - query_start > \$1 OR current_timestamp - xact_start > \$1);" > /etc/zabbix/zabbix_agentd.d/query/longquery.sql && \
  echo "SELECT CASE setting WHEN 'off' THEN 0 WHEN 'on' THEN 1 WHEN 'always' THEN 2 END FROM pg_catalog.pg_settings WHERE name = 'archive_mode';" > /etc/zabbix/zabbix_agentd.d/query/archivemode.sql && \
  echo 'SELECT CASE WHEN pg_is_in_recovery() THEN pg_is_wal_replay_paused()::integer ELSE 0 END;' > /etc/zabbix/zabbix_agentd.d/query/rpause.sql && \
  echo "SELECT string_agg(s,'') FROM (SELECT s FROM (SELECT 1 as n, 0 as seqno, '<TABLE>' as s UNION SELECT 2 as n, 0 as seqno, '<TR><TH>seqno</TH><TH>name</TH><TH>setting</TH><TH>applied</TH><TH>sourcefile</TH></TR>' as s UNION SELECT 3 as n, seqno, '<TR><TD>' || seqno || '</TD><TD>' || name || '</TD><TD>' || setting || '</TD><TD>' || applied || '</TD><TD>' || sourcefile || '</TD></TR>' as s FROM pg_catalog.pg_file_settings UNION SELECT 4 as n, 0 as seqno, '</TABLE>' as s ) tmp ORDER BY n, seqno) res;" > /etc/zabbix/zabbix_agentd.d/query/pgconfig.sql && \
  chown -R zabbix:zabbix /etc/zabbix/zabbix_agentd.d/query && \
  apt-get clean all && \
  unset DEBIAN_FRONTEND

USER zabbix

RUN echo 'alias nocomments="sed -e :a -re '"'"'s/<\!--.*?-->//g;/<\!--/N;//ba'"'"' | sed -e :a -re '"'"'s/\/\*.*?\*\///g;/\/\*/N;//ba'"'"' | grep -v -P '"'"'^\s*(#|;|--|//|$)'"'"'"' >> ~/.bashrc

WORKDIR /etc/zabbix
