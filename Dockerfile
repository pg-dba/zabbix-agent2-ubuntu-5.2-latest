FROM zabbix/zabbix-agent2:ubuntu-5.2-latest

USER root

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get -y install iputils-ping fping dnsutils telnet && \
    apt-get -y install lsb-release gnupg2 wget && \
    sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    mkdir /var/lib/postgresql && \
    groupadd -g 999 postgres && \
    useradd -u 999 -g 999 postgres -d /var/lib/postgresql -s /bin/bash && \
    apt-get -y install postgresql-client-10 && \
    cd /usr/sbin; ln -s /usr/bin/fping && \
    chown root:zabbix /usr/bin/fping && \
    chmod u+s /usr/bin/fping && \
    mkdir -p /etc/zabbix/zabbix_agentd.d/query && \
    mkdir -p /etc/zabbix/zabbix_agentd.d/scripts && \
    echo 'UserParameter=pgsql.config[*],/etc/zabbix/zabbix_agentd.d/scripts/pg_config.sh $1 $2 $3' > /etc/zabbix/zabbix_agentd.d/userparameter_proc.conf && \
    sed -i 's/# Plugins.Postgres.CustomQueriesPath=/Plugins.Postgres.CustomQueriesPath=\/etc\/zabbix\/zabbix_agentd.d\/query/' /etc/zabbix/zabbix_agent2.conf && \
    echo "SELECT '<TABLE><TR><TH>test</TH></TR><TR><TD>тест</TD></TR></TABLE>' as Result;" > /etc/zabbix/zabbix_agentd.d/query/test.sql && \
    echo 'SELECT COUNT(*) FROM pg_ls_waldir() WHERE name ~ '"'"'^[0-9A-F]{24}$'"'"';' > /etc/zabbix/zabbix_agentd.d/query/walcount.sql && \
    echo 'SELECT COUNT(*) FROM pg_replication_slots;' > /etc/zabbix/zabbix_agentd.d/query/rslot.sql && \
    echo "SELECT COUNT(*) FROM pg_stat_activity WHERE (backend_xmin IS NOT NULL OR backend_xid IS NOT NULL) AND (current_timestamp - query_start > \$1 OR current_timestamp - xact_start > \$1);" > /etc/zabbix/zabbix_agentd.d/query/longquery.sql && \
    echo "SELECT CASE setting WHEN 'off' THEN 0 WHEN 'on' THEN 1 WHEN 'always' THEN 2 END FROM pg_catalog.pg_settings WHERE name = 'archive_mode';" > /etc/zabbix/zabbix_agentd.d/query/archivemode.sql && \
    echo 'SELECT CASE WHEN pg_is_in_recovery() THEN pg_is_wal_replay_paused()::integer ELSE 0 END;' > /etc/zabbix/zabbix_agentd.d/query/rpause.sql && \
    echo "SELECT string_agg(s,'') as result FROM (SELECT s FROM (SELECT 1 as n, 0 as seqno, '<TABLE>' as s UNION SELECT 2 as n, 0 as seqno, '<TR><TH>seqno</TH><TH>name</TH><TH>setting</TH><TH>applied</TH><TH>sourcefile</TH></TR>' as s UNION SELECT 3 as n, seqno, '<TR><TD>' || seqno || '</TD><TD>' || name || '</TD><TD>' || setting || '</TD><TD>' || applied || '</TD><TD>' || sourcefile || '</TD></TR>' as s FROM pg_catalog.pg_file_settings UNION SELECT 4 as n, 0 as seqno, '</TABLE>' as s ) tmp ORDER BY n, seqno) res;" > /etc/zabbix/zabbix_agentd.d/query/pgconfig.sql && \
    apt-get -y purge wget && \
    apt-get clean all && \
    unset DEBIAN_FRONTEND

COPY *.sh /etc/zabbix/zabbix_agentd.d/scripts/

RUN chown -R zabbix:zabbix /etc/zabbix/zabbix_agentd.d && \
    chmod 700 /etc/zabbix/zabbix_agentd.d/scripts/*.sh

USER zabbix

RUN echo 'alias nocomments="sed -e :a -re '"'"'s/<\!--.*?-->//g;/<\!--/N;//ba'"'"' | sed -e :a -re '"'"'s/\/\*.*?\*\///g;/\/\*/N;//ba'"'"' | grep -v -P '"'"'^\s*(#|;|--|//|$)'"'"'"' >> ~/.bashrc

WORKDIR /etc/zabbix

#  echo "SELECT replace(replace(string_agg(s,''), '<', '&#60;'), '>', '&#62;') as Result FROM (SELECT s FROM (SELECT 1 as n, 0 as seqno, '<TABLE>' as s UNION SELECT 2 as n, 0 as seqno, '<TR><TH>seqno</TH><TH>name</TH><TH>setting</TH><TH>applied</TH><TH>sourcefile</TH></TR>' as s UNION SELECT 3 as n, seqno, '<TR><TD>' || seqno || '</TD><TD>' || name || '</TD><TD>' || setting || '</TD><TD>' || applied || '</TD><TD>' || sourcefile || '</TD></TR>' as s FROM pg_catalog.pg_file_settings UNION SELECT 4 as n, 0 as seqno, '</TABLE>' as s ) tmp ORDER BY n, seqno) res;" > /etc/zabbix/zabbix_agentd.d/query/pgconfig.sql && \
