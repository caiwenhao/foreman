#!/bin/bash

function game_metrics() {
	
	project=${1}

	ifdata=$(/usr/bin/iftop -i any -s 10 -t -N -P -B -L 10000 2>/dev/null)
	for game in `ls -d /data/${project}_*_*`
	do
		if [ "$(pgrep -f ${game})" != "" ]
		then
			server_id=$(echo ${game} | awk -F_ '{print $NF}')
			node_name=$(echo ${game} | awk -F/ '{print $NF}')
			game_name=$(echo ${game} | awk -F'/' '{print $3}')

			CONFIG="${game}/server/setting/common.config"
			GW=$(awk -F'[,}{]' '/gateway_port/{gsub(/ */,"",$0);print $3}' ${CONFIG})
			ret=$(echo "${ifdata}" | sed -n "/:${GW}/{p;n;p}")
			send=$(awk '{if($0~/=>/){if($NF~/KB/){sub(/KB/,"",$NF);sum+=$NF*1024}else{sub(/B/,"",$NF);sum+=$NF}}}END{printf("%d",sum*8/10)}' <<< "${ret}")
			recv=$(awk '{if($0~/<=/){if($NF~/KB/){sub(/KB/,"",$NF);sum+=$NF*1024}else{sub(/B/,"",$NF);sum+=$NF}}}END{printf("%d",sum*8/10)}' <<< "${ret}")

			stats=$(${game}/server/mgectl exprs "common_debugger:i()")
			online=$(echo "${stats}" | awk '/Online Roles/{print $4}')
			register=$(echo "${stats}" | awk '/Total Roles/{print $4}')
			erl_node_mem=$(echo "${stats}" | awk '/Node Total Memory/{printf "%0.2f\n",$(NF-1)/1024}')
			erl_mnesia_mem=$(echo "${stats}" | awk '/Node Total Mnesia Memory/{printf "%0.2f\n",$(NF-1)/1024}')
			mlognum=$(${game}/server/mgectl lognum)
			
			game_cpu_used=$(ps aux | /bin/grep "name ${game_name}\b" | /bin/grep -v grep | awk '{print $3}')
			echo "application.game.cpu_used `date +%s` ${game_cpu_used} unit=u_entry server_id=${server_id} node_name=${node_name}"

			echo "application.game.net_traffic `date +%s` ${recv} direction=recv unit=u_B/s server_id=${server_id} node_name=${node_name}"
			echo "application.game.net_traffic `date +%s` ${send} direction=send unit=u_B/s server_id=${server_id} node_name=${node_name}"
			
			if ! echo ${online} | grep -q '[^0-9]'  
			then
				echo "application.game.online `date +%s` ${online} unit=u_entry server_id=${server_id} node_name=${node_name}"
			else
				echo "application.game.online `date +%s` 0 unit=u_entry server_id=${server_id} node_name=${node_name}"
			fi
			if ! echo ${register} | grep -q '[^0-9]'
			then
				echo "application.game.register `date +%s` ${register} unit=u_entry server_id=${server_id} node_name=${node_name}"
			else
				echo "application.game.register `date +%s` 0 unit=u_entry server_id=${server_id} node_name=${node_name}"
			fi

			if ! echo ${erl_node_mem} | grep -q '[^.0-9]'
			then
				echo "application.erlang.node_mem `date +%s` ${erl_node_mem} unit=u_Gb server_id=${server_id} node_name=${node_name}"
			else
				echo "application.erlang.node_mem `date +%s` 0.00 unit=u_Gb server_id=${server_id} node_name=${node_name}"
			fi  

			if ! echo ${erl_mnesia_mem} | grep -q '[^.0-9]'
			then
				echo "application.erlang.mnesia_mem `date +%s` ${erl_mnesia_mem} unit=u_Gb server_id=${server_id} node_name=${node_name}"
			else
				echo "application.erlang.mnesia_mem `date +%s` 0.00 unit=u_Gb server_id=${server_id} node_name=${node_name}"
			fi
	    
			if ! echo ${mlognum} | grep -q '[^.0-9]'
			then
				echo "application.erlang.mlognum `date +%s` ${mlognum} unit=u_entry server_id=${server_id} node_name=${node_name}"
			else
				echo "application.erlang.mlognum `date +%s` 0.00 unit=u_entry server_id=${server_id} node_name=${node_name}"
			fi
		fi
	done

	# sleep 5
}
