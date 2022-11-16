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
  chown -R zabbix:zabbix /etc/zabbix/zabbix_agentd.d/query && \
  apt-get clean all && \
  unset DEBIAN_FRONTEND

USER zabbix

RUN echo 'alias nocomments="sed -e :a -re '"'"'s/<\!--.*?-->//g;/<\!--/N;//ba'"'"' | sed -e :a -re '"'"'s/\/\*.*?\*\///g;/\/\*/N;//ba'"'"' | grep -v -P '"'"'^\s*(#|;|--|//|$)'"'"'"' >> ~/.bashrc
