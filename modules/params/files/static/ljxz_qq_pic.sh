#!/bin/bash
curr_time=$(/usr/bin/stat /data/ljxz/web/static/1|/bin/grep Change)
last_time=$(cat /data/sh/ljxz_qq_pic.txt)
if [ "${curr_time}" != "${last_time}" ];then
    echo ${curr_time} > /data/sh/ljxz_qq_pic.txt
    /usr/bin/rsync -avP --timeout=180 --password-file=/etc/rsync.pass /data/ljxz/web/static/1/* rsy_user@122.224.103.138::mingchao_ljxz_pic >> /data/logs/ljxz_qq_pic.log
fi
