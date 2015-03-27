#!/bin/bash 

while :
do
	#首先记录当前网卡eth1已经接收数据，单位是字节
	in_bytes_eth1_start=$(awk -F'[ :]*' '/eth1/{print $3}' /proc/net/dev)
	
	#首先记录当前网卡eth1已经发送出去数据，单位是字节
	out_bytes_eth1_start=$(awk '/eth1/{print $9}' /proc/net/dev)

	#首先记录当前网卡eth0已经接收数据，单位是字节
	in_bytes_eth0_start=$(awk -F'[ :]*' '/eth0/{print $3}' /proc/net/dev)
	
	#首先记录当前网卡eth0已经发送出去数据，单位是字节
	out_bytes_eth0_start=$(awk '/eth0/{print $9}' /proc/net/dev)
	
	#暂停5秒
	sleep 5

	#记录5秒以后网卡eth1已经接收数据，单位是字节
	in_bytes_eth1_end=$(awk -F'[ :]*' '/eth1/{print $3}' /proc/net/dev)
	
	#记录5秒以后网卡eth1已经发送出去数据，单位是字节
        out_bytes_eth1_end=$(awk '/eth1/{print $9}' /proc/net/dev)

	#记录5秒以后网卡eth0已经接收数据，单位是字节
        in_bytes_eth0_end=$(awk -F'[ :]*' '/eth0/{print $3}' /proc/net/dev)
	
	#记录5秒以后网卡eth0已经发送出去数据，单位是字节
        out_bytes_eth0_end=$(awk '/eth0/{print $9}' /proc/net/dev)
	
	#计算eth0、eth1入口和出口流量 
	bit_eth1_in=$(echo ${in_bytes_eth1_end} ${in_bytes_eth1_start} | awk '{printf "%0.2f",($1-$2)*8/5}')
	bit_eth1_out=$(echo ${out_bytes_eth1_end} ${out_bytes_eth1_start} | awk '{printf "%0.2f",($1-$2)*8/5}')
	bit_eth0_in=$(echo ${in_bytes_eth0_end} ${in_bytes_eth0_start} | awk '{printf "%0.2f",($1-$2)*8/5}')
	bit_eth0_out=$(echo ${out_bytes_eth0_end} ${out_bytes_eth0_start} | awk '{printf "%0.2f",($1-$2)*8/5}')
	
	echo "system.network.traffic `date +%s` ${bit_eth1_in} interface=eth1 direction=recv unit=u_b/s"
	echo "system.network.traffic `date +%s` ${bit_eth0_in} interface=eth0 direction=recv unit=u_b/s"
	echo "system.network.traffic `date +%s` ${bit_eth1_out} interface=eth1 direction=send unit=u_b/s" 
	echo "system.network.traffic `date +%s` ${bit_eth0_out} interface=eth0 direction=send unit=u_b/s" 

	ret=$(/usr/sbin/ss | awk 'BEGIN{e=0;c=0}{if($0~/ESTAB/){e+=1};if($0~/CLOSE-WAIT/){c+=1}}END{print e, c}')
	estab=$(awk '{print $1}' <<< "${ret}")
	clowa=$(awk '{print $2}' <<< "${ret}")

	echo "system.network.estab `date +%s` ${estab} unit=u_entry"
	echo "system.network.close_wait `date +%s` ${clowa} unit=u_entry"

done 
