#!/bin/bash

COLLECTORDIR=/usr/local/services/tcollector/collectors/0
project=$(sed -rn '/server_role/,/project/{/project/{s/project\s*=\s*//;p}}' /data/msalt/conf/msalt.conf)
roles=$(sed -rn '/node_role/{s/node_role\s*=\s*//;p}' /data/msalt/conf/msalt.conf)
if [[ "${roles}" =~ gmain ]]; then 
        source ${COLLECTORDIR}/lib/game_metrics.sh
        while :
        do
                game_metrics "${project}"
                sleep 10
        done
else
	while :
	do
		sleep 600
	done
fi
