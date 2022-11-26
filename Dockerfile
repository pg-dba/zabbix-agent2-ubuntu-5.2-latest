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
  echo 'SELECT COUNT(*) FROM pg_ls_waldir() WHERE name ~ '"'"'^[0-9A-F]{24}$'"'"';' > /etc/zabbix/zabbix_agentd.d/query/walcount.sql && \
  echo 'SELECT COUNT(*) FROM pg_replication_slots;' > /etc/zabbix/zabbix_agentd.d/query/rslot.sql && \
  echo "SELECT COUNT(*) FROM pg_stat_activity WHERE (backend_xmin IS NOT NULL OR backend_xid IS NOT NULL) AND (current_timestamp - query_start > \$1 OR current_timestamp - xact_start > \$1);" > /etc/zabbix/zabbix_agentd.d/query/longquery.sql && \
  echo "SELECT CASE setting WHEN 'off' THEN 0 WHEN 'on' THEN 1 WHEN 'always' THEN 2 END FROM pg_catalog.pg_settings WHERE name = 'archive_mode';" > /etc/zabbix/zabbix_agentd.d/query/archivemode.sql && \
  echo 'SELECT pg_is_wal_replay_paused()::integer;' > /etc/zabbix/zabbix_agentd.d/query/rpause.sql && \
  chown -R zabbix:zabbix /etc/zabbix/zabbix_agentd.d/query && \
  apt-get clean all && \
  unset DEBIAN_FRONTEND

USER zabbix

RUN echo 'alias nocomments="sed -e :a -re '"'"'s/<\!--.*?-->//g;/<\!--/N;//ba'"'"' | sed -e :a -re '"'"'s/\/\*.*?\*\///g;/\/\*/N;//ba'"'"' | grep -v -P '"'"'^\s*(#|;|--|//|$)'"'"'"' >> ~/.bashrc

WORKDIR /etc/zabbix
