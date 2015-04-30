#!/bin/bash

COLLECTORDIR=/usr/local/tcollector/collectors/0
project=$(/bin/grep -Po '(?<=^project = )\w+' /etc/msalt/msalt.conf)
roles=$(sed -rn '/node_role/{s/node_role\s*=\s*//;p}' /etc/msalt/msalt.conf)
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
