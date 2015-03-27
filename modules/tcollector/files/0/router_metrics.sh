#!/bin/bash

COLLECTORDIR=/usr/local/services/tcollector/collectors/0
project=$(sed -rn '/server_role/,/project/{/project/{s/project\s*=\s*//;p}}' /data/msalt/conf/msalt.conf)
roles=$(sed -rn '/node_role/{s/node_role\s*=\s*//;p}' /data/msalt/conf/msalt.conf)

if [[ "${roles}" =~ router ]]; then
        source ${COLLECTORDIR}/lib/mysql_metrics.sh
        source ${COLLECTORDIR}/lib/memcached_metrics.sh
        source  ${COLLECTORDIR}/lib/cgi_metrics.sh
        while :
        do
                mysql_metrics
                memcached_metrics
                cgi_metrics
                sleep 10
        done
else
	while : 
	do
		sleep 600
	done
fi
