#!/bin/bash

COLLECTORDIR=/usr/local/tcollector/collectors/0
project=$(/bin/grep -Po '(?<=^project = )\w+' /etc/msalt/msalt.conf)
roles=$(sed -rn '/node_role/{s/node_role\s*=\s*//;p}' /etc/msalt/msalt.conf)
if [[ "${roles}" =~ admin ]]; then 
	source ${COLLECTORDIR}/lib/mysql_metrics.sh
	source ${COLLECTORDIR}/lib/mlog_metrics.sh
	source ${COLLECTORDIR}/lib/memcached_metrics.sh
	while :
	do
		mysql_metrics
		mlog_metrics
		memcached_metrics
		sleep 10
	done
else
	while :
	do
		sleep 600
	done
fi
