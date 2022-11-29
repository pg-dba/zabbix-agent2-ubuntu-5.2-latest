#!/bin/bash
# pg_config.sh

URI=$1
URI="${URI/tcp/postgres}"
USER=$2
PASSWORD=$3
PGPASSWORD=${PASSWORD} PGCONNECT_TIMEOUT=10 psql ${URI}/postgres -U ${USER} -At -c "SELECT string_agg(s,'') as result FROM (SELECT s FROM (SELECT 1 as n, 0 as seqno, '<TABLE>' as s UNION SELECT 2 as n, 0 as seqno, '<TR><TH>seqno</TH><TH>name</TH><TH>setting</TH><TH>applied</TH><TH>sourcefile</TH></TR>' as s UNION SELECT 3 as n, seqno, '<TR><TD>' || seqno || '</TD><TD>' || name || '</TD><TD>' || setting || '</TD><TD>' || applied || '</TD><TD>' || sourcefile || '</TD></TR>' as s FROM pg_catalog.pg_file_settings UNION SELECT 4 as n, 0 as seqno, '</TABLE>' as s ) tmp ORDER BY n,seqno) res;"

# userparameter_proc.conf
# UserParameter=pgsql.config[*],/etc/zabbix/zabbix_agentd.d/scripts/pg_config.sh
# sudo -su zabbix zabbix_agent2 -t pgsql.config["tcp://postgres.myappstack:5432","zbx_monitor","P@ssw0rd"]
