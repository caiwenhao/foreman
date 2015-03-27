#!/bin/bash 

while :
do
	disks=$(df | awk '{if($NF=="/"){a=gensub(/\/dev\//,"","g",$1)};if($NF=="/data"){b=gensub(/\/dev\//,"","g",$1)}}END{print a,b}')
	rootdisk=$(awk '{print $1}' <<< "${disks}")
	datadisk=$(awk '{print $2}' <<< "${disks}")
        iostats="$(iostat -x ${disks} 1 5)"

	util=$(echo "$iostats" | awk -vd=${rootdisk} '$0 ~ d{print $NF}' | sed '1d' | sort -nr | head -n1)
	svctm=$(echo "$iostats" | awk -vd=${rootdisk} '$0 ~ d{print $(NF-1)}' | sed '1d' | sort -nr | head -n1)
	await=$(echo "$iostats" | awk -vd=${rootdisk} '$0 ~ d{print $(NF-2)}' | sed '1d' | sort -nr | head -n1)
	echo "system.iostat.util `date +%s` ${util} device=root unit=u_percent"
	echo "system.iostat.await `date +%s` ${await} device=root unit=u_ms"
	echo "system.iostat.svctm `date +%s` ${svctm} device=root unit=u_ms"

	util=$(echo "$iostats" | awk -vd=${datadisk} '$0 ~ d{print $NF}' | sed '1d' | sort -nr | head -n1)
	svctm=$(echo "$iostats" | awk -vd=${datadisk} '$0 ~ d{print $(NF-1)}' | sed '1d' | sort -nr | head -n1)
	await=$(echo "$iostats" | awk -vd=${datadisk} '$0 ~ d{print $(NF-2)}' | sed '1d' | sort -nr | head -n1)
	echo "system.iostat.util `date +%s` ${util} device=data unit=u_percent"
	echo "system.iostat.await `date +%s` ${await} device=data unit=u_ms"
	echo "system.iostat.svctm `date +%s` ${svctm} device=data unit=u_ms"
        
	idle=$(echo "$iostats" | awk '/idle/{f=1;next}f{a=!a?$NF:a","$NF;f=0}END{print "print sum(["a"])/len(["a"])"}' | python)
        echo "system.iostat.idle `date +%s` ${idle} unit=u_percent"

        avail=$(df -k /data | awk '$NF~/data/{print $(NF-2)/1024/1024}')
        echo "system.data.avail `date +%s` ${avail} unit=u_G"
done 
