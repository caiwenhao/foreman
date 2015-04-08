#!/bin/bash
#by caiwenhao  2014-07-29
local_ip=$(/sbin/ifconfig eth0 |awk '/inet addr/ {print $2}'|sed 's/addr://')
static_rsync_serevr="14.18.206.201"
static_dir="/data/ljxz/web/static"
rtx_users="caiwenhao lidingsuo houzhenghui yangjianming zhengheng wangyang chenliuguang qiuyiming nijunxi zhangjianhao litianhong caisiqiang xiezhigang"
project=`cat /root/.bashrc | grep "PS1" | awk -F '_' '{print $2}'`
rsync_times=10

function send_rtx(){
    ret_msg=${ret_msg}"\n"$1
    if
        echo $ret_msg|/bin/grep ${local_ip} >/dev/null 2>&1
	then
	    continue    
	else
            ret_msg="ljxz_${project}${local_ip}${ret_msg}"
	fi
	ret_msg=$(echo "$ret_msg"|sed 's/\\n/%0d%0a/g'|sed 's/ /+/g'|sed 's/&/%26/g')
	for receiver in ${rtx_users}
	do
		key='MINGCHAO::API::RTX::4YHb&fovu^!6Kjh'
		time=`date +%s`
		msg=$(python -c "import base64;print base64.b64encode(base64.b64encode(\"${ret_msg}\"))")
		CheckSum=`echo -n "${receiver}${ret_msg}${time}${key}"| openssl dgst -md5 | awk '{print $NF}'`
		/usr/bin/curl -s -G http://call.mingchaoonline.com/rtx/mc_api_rtx_notice.php -d receiver=${receiver} -d msg=${msg} -d stamp=${time} -d sign=${CheckSum}
	done
}

function rysnc_pro(){
	let "rsync_times=${rsync_times}-1"
	/usr/bin/rsync -av --delete --progress --timeout=60 --port=10873 ljxz_static@${static_rsync_serevr}::${tag}/${version} ${static_dir} --password-file=/data/conf/rsync/rsyncd.pass 1> ${rsycn_pro_log} 2> ${rsycn_err_log}
	result=$(tail ${rsycn_pro_log}|/bin/grep "total size is")
	if [ -s ${rsycn_err_log} -a ${rsync_times} -ne 0 ];
	then
		rysnc_pro
	elif [ -s ${rsycn_err_log} -a ${rsync_times} -eq 0 ];
	then
		send_rtx "前端同步出错了,请查看日志 ${rsycn_err_log}"
        echo "请手动执行同步：/usr/bin/rsync -av --delete --progress --timeout=60 --port=10873 ljxz_static@${static_rsync_serevr}::${tag}/${version} ${static_dir} --password-file=/data/conf/rsync/rsyncd.pass" >> ${rsycn_err_log} 
	elif [ -n "${result}" ];
	then
		result_msg=$(du -sh ${static_dir}/${version}|awk '{print $1}' )
		send_rtx "同步成功，资源大小:${result_msg}"
	else
		send_rtx "什么也没做,重复发版了吗？"	
	fi
}

function rsysc_static(){
	if [ ! $# -eq 2 ] ; then
		echo "tag version"
		exit 1
	fi
	tag=$1
	version=$2
	job_time=$(date +'%Y-%m-%d_%H%M%S')
	current_version=$(ls ${static_dir} 2>/dev/null|xargs -n1|/bin/grep -E '[0-9]+$'|/bin/grep -v ${version}|sort -n |tail -1)
	rsycn_pro_log="/data/logs/rsysnc_static/${tag}_${version}_${job_time}.log"
	rsycn_err_log="/data/logs/rsysnc_static/${tag}_${version}_${job_time}.err"
	mkdir -p /data/logs/rsysnc_static
	if [ -n "${current_version}" -a ! -d "${static_dir}/${version}" ];
	then
		/usr/bin/rsync -aq ${static_dir}/${current_version}/ ${static_dir}/${version}
	fi
	rysnc_pro
}

task=$(/usr/bin/curl -s "http://transfer.mingchaoonline.com:62626/?name=ljxz_static_${local_ip}&opt=get&auth=COIBTBPRFAKWXBJB")
if [ "${task}" != "HTTPSQS_GET_END" -a -n "${task}" ];
then
	tag=$(echo ${task}|awk -F\: '{print $1}') 
    version_1=$(echo ${task}|awk -F\: '{print $2}')
	version=$(rsync --timeout=60 --port=10873 ljxz_static@${static_rsync_serevr}::${tag} --password-file=/data/conf/rsync/rsyncd.pass|awk '{print $5}'|/bin/grep -E [0-9]+|/bin/grep -w ${version_1})
	if [ -z "${tag}" -o -z "${version}" ];
	then
                send_rtx "接收到错误的发前端任务:${tag} ${version_1}"
		continue
	else

		send_rtx "接收到发前端任务:${tag} ${version}"
		rsysc_static ${tag} ${version}
	fi
fi



