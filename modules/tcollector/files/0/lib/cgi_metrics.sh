#!/bin/bash

function cgi_metrics() {
	stats=$(ps aux | /bin/grep php-cg[i])
	mem_used=$(awk '{sum+=$6}END{print sum/1024/1024}' <<< "${stats}")
	num=$(awk 'END{print NR}' <<< "${stats}")

	echo "application.cgi.mem_used `date +%s` ${mem_used} unit=u_G"
	echo "application.cgi.num `date +%s` ${num} unit=u_entry"

	# sleep 10
}
