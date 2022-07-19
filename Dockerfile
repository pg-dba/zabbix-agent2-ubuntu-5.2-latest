FROM zabbix/zabbix-agent2:ubuntu-5.2-latest

USER root

RUN export DEBIAN_FRONTEND=noninteractive && \
  apt-get update && \
  apt-get -y install iputils-ping fping dnsutils telnet && \
  cd /usr/sbin; ln -s /usr/bin/fping && \
  chown root:zabbix /usr/bin/fping && \
  chmod u+s /usr/bin/fping && \
  apt-get clean all && \
  unset DEBIAN_FRONTEND

USER zabbix
