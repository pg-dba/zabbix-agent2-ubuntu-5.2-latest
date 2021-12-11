FROM zabbix/zabbix-agent2:ubuntu-5.2-latest

ENV DEBIAN_FRONTEND noninteractive

USER root
RUN apt-get update
RUN apt-get -y install iputils-ping fping dnsutils telnet
RUN cd /usr/sbin; ln -s /usr/bin/fping
RUN chown root:zabbix /usr/bin/fping
RUN chmod u+s /usr/bin/fping
RUN apt-get clean all
USER zabbix
