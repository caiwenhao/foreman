#!/bin/bash

function redis_metrics() {
	REDISCLI=$(which redis-cli)
	stats=$(${REDISCLI} -a "$(awk '/^requirepass/{print $2}' /etc/redis.conf)" INFO | dos2unix)
	mem_used=$(awk -F':' '/used_memory:/{printf "%0.2f\n", $2/1024/1024}' <<< "${stats}")
	conn=$(awk -F':' '/connected_clients:/{print $2}' <<< "${stats}")
	hits=$(awk -F':' '/keyspace_hits:/{print $2}' <<< "${stats}")
	misses=$(awk -F':' '/keyspace_misses:/{print $2}' <<< "${stats}")
	key_hit_rate=$(echo "${hits}" "${misses}" | awk '{printf "%0.2f\n", $1/($1+$2)*100}')

	echo "application.redis.mem_used `date +%s` ${mem_used} unit=u_M"
	echo "application.redis.connected `date +%s` ${conn} unit=u_entry"
	echo "application.redis.key_hit_rate `date +%s` ${key_hit_rate} unit=u_percent"

	# sleep 10
}
