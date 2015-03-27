#!/bin/bash 

while :
do
	lavg_1=$(awk '{print $1}' /proc/loadavg)
	lavg_5=$(awk '{print $2}' /proc/loadavg)
	lavg_15=$(awk '{print $3}' /proc/loadavg)
	echo "system.load.1min `date +%s` ${lavg_1} unit=u_num"
	echo "system.load.5min `date +%s` ${lavg_5} unit=u_num"
	echo "system.load.15min `date +%s` ${lavg_15} unit=u_num"
	sleep 15
done 
