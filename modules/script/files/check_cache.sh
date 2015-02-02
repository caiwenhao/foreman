#!/bin/bash
#日期、时间格式
date_format=`date +"%Y-%m-%d %H:%M:%S"`
#剩余内存
free_mem=$(/usr/bin/vmstat -s -S M | awk '/free memory/{print $1}')
#占用swap cache大小
swap_cache=$(/usr/bin/vmstat -s -S M | awk '/swap cache/{print $1}')
if [[ $free_mem -lt 2500 ]]
then
	sync && sync 
	echo 3 > /proc/sys/vm/drop_caches
	echo 3 > /proc/sys/vm/drop_caches
else
	if [[ $swap_cache -gt 3000 ]]
	then
		sync && sync 
		echo 3 > /proc/sys/vm/drop_caches
		echo 3 > /proc/sys/vm/drop_caches
	fi
fi
