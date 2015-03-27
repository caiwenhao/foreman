#!/bin/bash

function memcached_metrics() {
	if which nc > /dev/null 2>&1; then
		NC=$(which nc)
	elif which netcat > /dev/null 2>&1; then
		NC=$(which netcat)
	fi

	mem_used1=$(ps aux | awk '/memcache[d].*11210/{printf "%0.2f\n", $6/1024}')
	mem_used2=$(ps aux | awk '/memcache[d].*11211/{printf "%0.2f\n", $6/1024}')
	
	stats1=$(echo "stats" | ${NC} 127.0.0.1 11210 | dos2unix)
	stats2=$(echo "stats" | ${NC} 127.0.0.1 11211 | dos2unix)
	
	curr_connections1=$(awk '/curr_connections/{print $3}' <<< "${stats1}")
	curr_connections2=$(awk '/curr_connections/{print $3}' <<< "${stats2}")
	cmd_get1=$(awk '/cmd_get/{print $3}' <<< "${stats1}")
	cmd_get2=$(awk '/cmd_get/{print $3}' <<< "${stats2}")
	get_hits1=$(awk '/get_hits/{print $3}' <<< "${stats1}")
	get_hits2=$(awk '/get_hits/{print $3}' <<< "${stats2}")
	if [ x"${cmd_get1}" = "x0" ]; then
		get_hits_rate1=0
	else
		get_hits_rate1=$(echo ${get_hits1} ${cmd_get1} | awk '{printf "%0.2f\n", $1/$2*100}')
	fi
	if [ x"${cmd_get2}" = "x0" ]; then
		get_hits_rate2=0
	else
		get_hits_rate2=$(echo ${get_hits2} ${cmd_get2} | awk '{printf "%0.2f\n", $1/$2*100}')
	fi

	echo "application.memcached.mem_used `date +%s` ${mem_used1} port=11210 unit=u_M"
	echo "application.memcached.mem_used `date +%s` ${mem_used2} port=11211 unit=u_M"
	echo "application.memcached.connections `date +%s` ${curr_connections1} port=11210 unit=u_entry"
	echo "application.memcached.connections `date +%s` ${curr_connections2} port=11211 unit=u_entry"
	echo "application.memcached.get_hits_rate `date +%s` ${get_hits_rate1} port=11210 unit=u_percent"
	echo "application.memcached.get_hits_rate `date +%s` ${get_hits_rate2} port=11211 unit=u_percent"

	# sleep 5
}
