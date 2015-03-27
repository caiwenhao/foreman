#!/bin/bash

while :
do
	process_num=$(ps aux | awk 'END{print NR-1}')
	echo "system.os.process_num `date +%s` ${process_num} unit=u_entry"
	opened_files_rate=$(cat /proc/sys/fs/file-nr | awk '{printf "%0.2f\n",$1/$3*100}')
	echo "system.os.opened_files_rate `date +%s` ${opened_files_rate} unit=u_percent"

	sleep 30
done
