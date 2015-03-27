#!/bin/bash

function mysql_metrics() {
	MYSQL=$(which mysql)
	MYSQLADMIN=$(which mysqladmin)

	stats=$(${MYSQLADMIN} -uroot -p`cat /data/save/mysql_root` extended-status -r -i1 -c 5)
	ips=$(awk '/Com_insert / && n1++ {a+=$4}END{print a/4}' <<< "${stats}")
	qps=$(awk '/Com_select / && n1++ {a+=$4}END{print a/4}' <<< "${stats}")
	tps=$(awk '/Com_insert / && n1++{a+=$4}/Com_update / && n2++{b+=$4}/Com_delete / && n3++{c+=$4}END{print a/4+b/4+c/4}' <<< "${stats}")
	echo "application.mysql.ips `date +%s` ${ips} unit=u_tps"
	echo "application.mysql.qps `date +%s` ${qps} unit=u_tps"
	echo "application.mysql.tps `date +%s` ${tps} unit=u_tps"

	conn=$(${MYSQL} -uroot -p`cat /data/save/mysql_root` -sNe 'show status' | awk '/Threads_connected/{print $2}')
	max_conn=$(${MYSQL} -uroot -p`cat /data/save/mysql_root` -sNe 'show variables like "max_connections"' | awk '{print $2}')
	conn_rate=$(echo ${conn} ${max_conn} | awk '{printf "%0.2f", $1/$2*100}')
	echo "application.mysql.connected `date +%s` ${conn} unit=u_entry"
	echo "application.mysql.connected_rate `date +%s` ${conn_rate} unit=u_percent"

	hits=$(${MYSQLADMIN} -uroot -p`cat /data/save/mysql_root` extended-status -r -i1 -c 1 | awk '{if($2=="Innodb_buffer_pool_reads"){rds=$4};if($2=="Innodb_buffer_pool_read_requests"){req=$4}}END{printf("%0.2f\n", 100*(1-(rds/req)))}')
	echo "application.mysql.buffer_hits `date +%s` ${hits} unit=u_percent"

	mem_used=$(ps aux | /bin/grep -w "mysql[d]" | awk '{print $6/1024/1024}')
	echo "application.mysql.mem_used `date +%s` ${mem_used} unit=u_G"

	# sleep 5
}
