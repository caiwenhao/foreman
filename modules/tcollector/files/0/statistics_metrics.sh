#!/bin/bash
##################
# 只用在mm机上运行
##################

project=$(sed -rn '/server_role/,/project/{/project/{s/project\s*=\s*//;p;q}}' /data/msalt/conf/msalt.conf)
agent=$(sed -rn '/server_role/,/agent/{/agent/{s/agent\s*=\s*//;p;q}}' /data/msalt/conf/msalt.conf)
roles=$(sed -rn '/node_role/{s/node_role\s*=\s*//;p}' /data/msalt/conf/msalt.conf)
while :
do
	if [[ "${roles}" =~ master ]]; then
		stats1=$(msalt-ctl game "${project}_${agent}_*" --exclude="${project}_${agent}_9..." game_roles.online --is_raw)
		game_num=$(awk '/game/{sum+=1}END{print sum}' <<< "${stats1}")
		online_total=$(awk '/game/{sum+=$4}END{print sum}' <<< "${stats1}")
		online_avg=$(echo "${game_num}" "${online_total}" | awk '{printf "%0.2f\n", $2/$1}')
		echo "application.game.all_games `date +%s` ${game_num} unit=u_entry"
		echo "statistics.game.game_num `date +%s` ${game_num} unit=u_entry"
		echo "statistics.game.online_total `date +%s` ${online_total} unit=u_entry"
		echo "statistics.game.online_avg `date +%s` ${online_avg} unit=u_entry"

		stats2=$(msalt-ctl game "${project}_${agent}_*" --exclude="${project}_${agent}_9..." cmd.call "ps aux | /bin/grep 'name {node}[@]' | /bin/awk '{print \$3,\$6/1024/1024}'" --is_raw)
		game_cpu_avg=$(awk '/game/{sum+=$4;cnt+=1}END{printf "%0.2f\n", sum/cnt}' <<< "${stats2}")
		game_mem_avg=$(awk '/game/{sum+=$5;cnt+=1}END{printf "%0.2f\n", sum/cnt}' <<< "${stats2}")
		echo "statistics.game.cpu_avg `date +%s` ${game_cpu_avg} unit=u_percent"
		echo "statistics.game.mem_avg `date +%s` ${game_mem_avg} unit=u_G"

		stats3=$(msalt-ctl game "${project}_${agent}_*" --exclude="${project}_${agent}_9..." cmd.call "awk '{print \$3}' /proc/loadavg" --is_raw)
		game_load_avg=$(awk '/game/{sum+=$4;cnt+=1}END{printf "%0.2f\n", sum/cnt}' <<< "${stats3}")
		echo "statistics.game.load_avg `date +%s` ${game_load_avg} unit=u_entry"
	
		stats4=$(msalt-ctl admin "*" cmd.call "iostat \$(df /data | awk '{print \$1}') -x | /bin/grep -P '^[a-z]' | awk '/[0-9]/{print \$12,\$14}'" --is_raw)
		admin_num=$(awk '/admin/{sum+=1}END{print sum}' <<< "${stats4}")
		admin_iowait_avg=$(awk '/admin/{sum+=$4;cnt+=1}END{printf "%0.2f\n", sum/cnt}' <<< "${stats4}")
		admin_ioutil_avg=$(awk '/admin/{sum+=$5;cnt+=1}END{printf "%0.2f\n", sum/cnt}' <<< "${stats4}")
		echo "statistics.admin.admin_num `date +%s` ${admin_num} unit=u_entry"
		echo "statistics.admin.iowait_avg `date +%s` ${admin_iowait_avg} unit=u_ms"
		echo "statistics.admin.ioutil_avg `date +%s` ${admin_ioutil_avg} unit=u_percent"

		stats5=$(msalt-ctl admin "*" cmd.call "/usr/local/bin/mysqladmin -uroot -p\`cat /data/save/mysql_root\` extended-status -r -i1 -c 5 | awk '/Com_insert / && n1++ {a+=\$4}END{print a/4}'" --is_raw)
		admin_mysql_ips_avg=$(awk '{if($4>0){sum+=$4;cnt+=1}}END{printf "%0.2f\n", sum/cnt}' <<< "${stats5}")
		echo "statistics.admin.mysql_ips_avg `date +%s` ${admin_mysql_ips_avg} unit=u_entry"

		stats6=$(msalt-ctl admin "*" cmd.call "df -k /data | awk '/data/{sub(/%/,\"\",\$5);print \$4/1024/1024, \$5}'" --is_raw)
		admin_data_used_percent=$(awk '/admin/{sum+=$5;cnt+=1}END{printf "%0.2f\n", sum/cnt}' <<< "${stats6}")
		admin_data_left=$(awk '/admin/{sum+=$4}END{printf "%0.2f\n", sum}' <<< "${stats6}")
		echo "statistics.admin.data_used_percent `date +%s` ${admin_data_used_percent} unit=u_percent"
		echo "statistics.admin.data_left `date +%s` ${admin_data_left} unit=u_G"
	fi
	sleep 600
done
