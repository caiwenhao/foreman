#!/bin/bash

while :
do
	stats=$(vmstat 1 5)
	cpu_used_rate=$(awk 'NR>3{used+=$(NF-4)+$(NF-3)+$(NF-1)+$NF}END{printf "%0.2f\n", used/4}' <<< "${stats}")
	cpu_switchs=$(awk 'NR>3{switchs+=$(NF-5)/1024}END{printf "%0.2f\n",switchs/4}' <<< "${stats}")
	echo "system.cpu.used_rate `date +%s` ${cpu_used_rate} unit=u_percent" 
	echo "system.cpu.switchs `date +%s` ${cpu_switchs} unit=u_k/s" 
done
