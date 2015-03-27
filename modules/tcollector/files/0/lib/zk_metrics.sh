#!/bin/bash

function zk_metrics() {
	if which nc > /dev/null 2>&1; then
		NC=$(which nc)
	elif which netcat > /dev/null 2>&1; then
		NC=$(which netcat)
	fi
	mem_used=$(ps aux | /bin/grep "zookeeper.*log4[j]" | awk '{printf "%0.2f\n", $6/1024/1024}')

	stats=$(echo "stat" | ${NC} 127.0.0.1 60001 | dos2unix)
	znodes_num=$(awk '/Node count/{print $3}' <<< "${stats}")
	conn=$(awk '/Connections/{print $2}' <<< "${stats}")
	recv=$(awk '/Received/{print $2}' <<< "${stats}")
	send=$(awk '/Sent/{print $2}' <<< "${stats}")

	echo "application.zk.mem_used `date +%s` ${mem_used} unit=u_G"
	echo "application.zk.connections `date +%s` ${conn} unit=u_entry"
	echo "application.zk.znodes_num `date +%s` ${znodes_num} unit=u_entry"
	echo "application.zk.network `date +%s` ${recv} direction=recv unit=u_B"
	echo "application.zk.network `date +%s` ${send} direction=send unit=u_B"

	sleep 10
}
