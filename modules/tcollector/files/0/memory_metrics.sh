#!/bin/bash


while :
do
	stats=$(free)
	used_rate=$(awk '/Mem/{printf "%0.2f\n",$3/$2*100}' <<< "${stats}")
	mem_free=$(awk '/Mem/{printf "%0.2f\n",$4/1024/1024}' <<< "${stats}")
	total_swap=$(awk '/Swap/{print $2}' <<< "${stats}")
	if [[ ${total_swap} -gt 0 ]]; then
		swap_rate=$(awk '/Swap/{printf "%0.2f\n",$3/$2*100}' <<< "${stats}")
	else
		swap_rate=0
	fi
	echo "system.mem.used_rate `date +%s` ${used_rate} unit=u_percent"
	echo "system.mem.free `date +%s` ${mem_free} unit=u_Gb"
	echo "system.mem.swap_rate `date +%s` ${swap_rate} unit=u_percent"
	majflt=$(sar -B 1 10 | awk 'NR==3{for(i=1;i<=NF;i++){if($i~/majflt/)f=i}}END{print $(f-1)}')
	echo "system.mem.majflt `date +%s` ${majflt} unit=u_entry"
done
