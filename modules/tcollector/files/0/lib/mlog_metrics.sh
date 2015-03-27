#!/bin/bash

function mlog_metrics() {

	stats=$(ps aux | /bin/grep "name mlog[@]")
	cpu_used=$(awk '{print $3}' <<< "${stats}")
	mem_used=$(awk '{print $6/1024/1024}' <<< "${stats}")
	echo "application.mlog.cpu_used `date +%s` ${cpu_used} unit=u_percent"
	echo "application.mlog.mem_used `date +%s` ${mem_used} unit=u_G"

	nodes_num=$(/usr/sbin/ss | awk '{if($1=="ESTAB"&&$4~/:20000/)sum+=1}END{print sum}')
	if [ x"${nodes_num}" = "x" ]; then
		echo "application.mlog.nodes_num `date +%s` 0 unit=u_entry"
	else
		echo "application.mlog.nodes_num `date +%s` ${nodes_num} unit=u_entry"
	fi

	# sleep 10

}
