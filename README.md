# 系统配置规范化

@(笔记本)[foreman,puppet,系统配置]

[toc]

---
##构建运维体系
**本文是构建运维体系的其中一个重要环节. **
开发阶段puppet模块安装命令:
`puppet module install -i /etc/puppet/environments/development/modules`

##基础系统配置
###DNS配置
/etc/resolv.conf
```
# DO NOT EDIT
options rotate timeout:1
nameserver 121.10.118.123
nameserver 114.114.114.114
nameserver 223.5.5.5
nameserver 223.6.6.6
nameserver 112.124.47.27
nameserver 202.96.128.143
nameserver 202.96.128.166
nameserver 202.96.128.86
```
---------
###时区配置
**RedHat**
```
yum install tzdata
cat > /etc/sysconfig/clock <<EOF
ZONE="Asia/Shanghai"
UTC=false
ARC=false
EOF
/bin/mv /etc/localtime /data/backup/tmp/
ln -s /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
```
------------------
**Suse**
```
zypper install timezone
/bin/mv  /etc/localtime /data/backup/tmp/
ln -s /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
```
---------
###时间同步
**RedHat**
```
yum install ntp
mkdir -p /etc/ntp
```
/etc/ntp.conf
```
# ntp.conf: Managed by puppet.
#
# Keep ntpd from panicking in the event of a large clock skew
# when a VM guest is suspended and resumed.
tinker panic 0

# Permit time synchronization with our time source, but do not
# permit the source to query or modify the service on this system.
restrict default kod nomodify notrap nopeer noquery
restrict -6 default kod nomodify notrap nopeer noquery
restrict 127.0.0.1
restrict -6 ::1

server time.nist.gov
server 0.asia.pool.ntp.org
server 1.asia.pool.ntp.org
server 2.asia.pool.ntp.org
server 3.asia.pool.ntp.org
server time-a.nist.gov
server time.windows.com
server ntp.fudan.edu.cn
server 61.129.42.44
server 43.119.133.233

# Driftfile.
driftfile /var/lib/ntp/drift
disable monitor
```

```
pkill ntpd
ntpdate cn.pool.ntp.org
/sbin/hwclock --systohc
service ntpd restart
```

---------

###selinux 
spiette-selinux
```shell
cat > /etc/sysconfig/selinux <<EOF
SELINUX=disabled
SELINUXTYPE=targeted
EOF
cat > /etc/selinux/config <<EOF
SELINUX=disabled
SELINUXTYPE=targeted
EOF
setenforce 0
```
---------

###终端环境语言
/etc/sysconfig/i18n
```
LANG="en_US.UTF-8"
SYSFONT="latarcyrheb-sun16"
```
---------
###bashrc
/root/.bashrc
```
# .bashrc
# User specific aliases and functions
# Source global definitions
if [ -f /etc/bashrc ]; then
. /etc/bashrc
fi
export LANG=en_US.UTF-8
export PS1='[\u@cwh_puppet_agent_192.168.137.3_61618_A \W]\$ '
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/usr/local/bin
```
------------------
###bash_profile
/root/.bash_profile
```
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
. ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/bin

export PATH
unset USERNAME

#实时记录历史命令
shopt -s histappend
PROMPT_COMMAND='history -a'

alias vi='vim'
alias cp='cp -i'
alias mv='mv -i'
alias rz='rz -bey'
alias grep='grep --colour=always'
alias rm='''echo -e "\033[40;32;1m【运维温馨提示】\033[0m \033[40;31;1;5m请不要轻易运行危险命令！\033[0m \033[40;33;1m rm \033[0m "'''
alias shutdown='''echo -e "\033[40;32;1m【运维温馨提示】\033[0m \033[40;31;1;5m请不要轻易运行危险命令！\033[0m \033[40;33;1m shutdown \033[0m"'''
alias init='''echo -e "\033[40;32;1m【运维温馨提示】\033[0m \033[40;31;1;5m请不要轻易运行危险命令！\033[0m \033[40;33;1m init \033[0m"'''
alias reboot='''echo -e "\033[40;32;1m【运维温馨提示】\033[0m \033[40;31;1;5m请不要轻易运行危险命令！\033[0m \033[40;33;1m reboot \033[0m"'''
alias halt='''echo -e "\033[40;32;1m【运维温馨提示】\033[0m \033[40;31;1;5m请不要轻易运行危险命令！\033[0m \033[40;33;1m halt \033[0m"'''
alias poweroff='''echo -e "\033[40;32;1m【运维温馨提示】\033[0m \033[40;31;1;5m请不要轻易运行危险命令！\033[0m \033[40;33;1m poweroff \033[0m"'''
alias pkill='''echo -e "\033[40;32;1m【运维温馨提示】\033[0m \033[40;31;1;5m请不要轻易运行危险命令！\033[0m \033[40;33;1m pkill \033[0m"'''
alias killall='''echo -e "\033[40;32;1m【运维温馨提示】\033[0m \033[40;31;1;5m请不要轻易运行危险命令！\033[0m \033[40;33;1m killall \033[0m"'''
alias kill='''echo -e "\033[40;32;1m【运维温馨提示】\033[0m \033[40;31;1;5m请不要轻易运行危险命令！\033[0m \033[40;33;1m kill \033[0m"'''
alias chgrp='chgrp --preserve-root'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
export MYSQL_PS1="\R:\m:\s\P>\_"

project_name=$(awk -F'@|_' '/PS1=/ {print $2}' /root/.bashrc)

usage_ming(){
	COMMAND_LIST="online_date online_num games_installed con_mysql mysql_root_pw genpasswd"
	for i in ${COMMAND_LIST}
	do
	echo -e "\033[32;49;1m$i\033[39;49;0m"
	done
	echo 'Please type "cat /root/.bash_profile" for more infomation'
}

online_date(){
	for i in $(ls /data | sed -n "/${project_name}_[0-9a-z]\{1,\}_[0-9]\{1,\}/p" | sort -t_ -k 2,2 -k 3,3n)
	do
		local AGENT="$(echo ${i} | awk -F'_' '{print $2}')"
		local SID="$(echo ${i} | awk -F'_' '{print $3}')"
		ONLINE_DATE=`awk -v FS=', *{ *{ *| *} *, *{ *| *} *} *} *. *' '/server_start_datetime/{gsub(/,/,"-",$2);gsub(/,/,":",$3);print $2,$3}' /data/${i}/server/setting/common.config`
		echo "${AGENT} ${SID}: ${ONLINE_DATE}"
	done
}

online_num(){
	ONLINE_SUM=0
	REG_NUM=""
	for i in $(ls /data | sed -n "/${project_name}_[0-9a-z]\{1,\}_[0-9]\{1,\}/p" | sort -t_ -k 2,2 -k 3,3n)
	do
		local AGENT="$(echo ${i} | awk -F'_' '{print $2}')"
		local SID="$(echo ${i} | awk -F'_' '{print $3}')"
		ONLINE_NUM=`/data/${i}/server/mgectl online`
		if [ $# -eq 2 ]
		then
			REG_NUM=`/data/${i}/server/mgectl reg`
		fi
		if [ ! $# -lt 1 ]
		then
			echo "${AGENT}_${SID}:${ONLINE_NUM} ${REG_NUM}"
		fi
		ONLINE_SUM=$((${ONLINE_SUM}+${ONLINE_NUM}))
	done
	echo ${ONLINE_SUM}
}

games_installed(){
	if [ -d /data/${project_name}/ ]
	then
		admin=$(ls /data/${project_name}/ | sed -n '/web_/p')
		if [ ! -z "${admin}" ]
		then
			echo -e "\033[0;31;1m已安装代理后台：\033[0m"
			ALL_SERVERS=$(for i in ${admin}
			do
				local AGENT="$(echo ${i} | awk -F'_' '{print $2}')"
				echo -e "${AGENT}"
			done)
			FORMAT_ALL_SERVERS=$(echo "${ALL_SERVERS}"|column -c 100 )
			echo -e "\033[0;32;1m${FORMAT_ALL_SERVERS}\033[0m"
		fi
	fi
	games=$(ls /data | sed -n "/${project_name}_[0-9a-z]\{1,\}_[0-9]\{1,\}/p" | sort -t_ -k 2,2 -k 3,3n)
	if [ ! -z "${games}" ]
	then
		echo -e "\033[0;31;1m当前机器上已安装$(echo ${games}|wc -w)个区服：\033[0m"
		game_list=$(ls /data | sed -n "/${project_name}_[0-9a-z]\{1,\}_[0-9]\{1,\}/p" | sort -t_ -k 2,2 -k 3,3n|awk -F "_" '{if($2==x){i=i","$3}else{if(NR>1){print i};if(length($2)>=8){i=$2"\t|\t"$3}else{i=$2"\t\t|\t"$3}}x=$2;y=$3}END{print i}')
		echo -e "\033[0;32;1m代理\t\t|\t区服\033[0m"
		info_s="$(echo "" | sed ':a; s/^/-/; /-\{60\}/b; ta')"
		echo -e "\033[0;32;1m${info_s}\033[0m"
		echo -e "\033[0;32;1m${game_list}\033[0m"
		echo -e "\033[0;32;1m${info_s}\033[0m"
	fi
}
games_installed

con_mysql(){
mysql -uroot -p$(cat /data/save/mysql_root)
}

mysql_root_pw(){
cat /data/save/mysql_root
}

genpasswd(){
local l=$1
[ "$l" == "" ] && l=16
tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${l} | xargs
}
```
-----
/etc/profile
```
#为历史命令加上时间
sed -i '/HISTTIMEFORMAT/d' /etc/profile
echo 'HISTTIMEFORMAT="%Y/%m/%d %H:%M:%S "' >> /etc/profile
#去掉段错误
ulimit -S -c 0 > /dev/null 2>&1 >> /etc/profile
```


-----
###创建必要的目录
```
mkdir -p /data/database
mkdir -p /data/logs
mkdir -p /data/backup/tmp
mkdir -p /dist/dist/
mkdir -p /dist/src/
mkdir -p /data/sh/
mkdir -p /data/conf/
```
--------------

###sysctl内核配置
/etc/sysctl.conf 
```
# Kernel sysctl configuration file for Red Hat Linux
#
# For binary values, 0 is disabled, 1 is enabled.  See sysctl(8) and
# sysctl.conf(5) for more details.

# Controls IP packet forwarding
net.ipv4.ip_forward = 0

# Controls source route verification
net.ipv4.conf.default.rp_filter = 1

# Do not accept source routing
net.ipv4.conf.default.accept_source_route = 0

# Controls the System Request debugging functionality of the kernel
kernel.sysrq = 0

# Controls whether core dumps will append the PID to the core filename.
# Useful for debugging multi-threaded applications.
kernel.core_uses_pid = 1

# Controls the use of TCP syncookies
net.ipv4.tcp_syncookies = 1

# Disable netfilter on bridges.

# Controls the default maxmimum size of a mesage queue
kernel.msgmnb = 0

# Controls the maximum size of a message, in bytes
kernel.msgmax = 65536

# Controls the maximum shared segment size, in bytes
kernel.shmmax = 4010803200

# Controls the maximum number of shared memory segments, in pages
kernel.shmall = 979200
kernel.shmmni = 4096
net.nf_conntrack_max = 655360
net.netfilter.nf_conntrack_max = 655360
net.netfilter.nf_conntrack_tcp_timeout_established = 1200
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.ip_local_reserved_ports = 3306,4369,8000-8300,9000-9300,20000-30000,61618
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_retries2 = 5
net.ipv4.tcp_max_tw_buckets = 180000
net.core.somaxconn = 1024
kernel.core_pattern = /data/tmp/core
```
```shell
sysctl -p
```
--------------
##配置第三源
为加快源的加载.生产环境只允许第三方源使用
/etc/yum.repos.d/mcyw.repo 
```
[mcyw]
gpgcheck=0
enabled=1
name=mcyw centos
baseurl=http://192.168.137.2:8080/centos/6.2/x86_64
priority=1
```
```
yum install yum-plugin-priorities
```
------------------
###ssh配置
编译支持历史命令记录的bash
```
cd /data/rpm/SOURCES/
wget http://ftp.gnu.org/gnu/bash/bash-4.3.30.tar.gz
tar xf bash-4.3.30.tar.gz
cd bash-4.3.30
```
config-top.h 下面两行的宏定义取消注释
```
#define SSH_SOURCE_BASHRC 该选项只针对 6 系列的系统(CentOS6.x,RHEL6.x等)
#define SYSLOG_HISTORY
```
bashhist.c  修改`bash_syslog_history`函数
```
void
bash_syslog_history (line)
 const char *line;
{
 char trunc[SYSLOG_MAXLEN];
 const char *p;
 p = getenv("NAME_OF_KEY");
 if (strlen(line) < SYSLOG_MAXLEN)
 syslog (SYSLOG_FACILITY|SYSLOG_LEVEL, "HISTORY: PID=%d PPID=%d SID=%d User=%s USER=%s CMD=%s", getpid(), getppid(), getsid(getpid()), current_user.user_name, p, line);
 else
 {
 strncpy (trunc, line, SYSLOG_MAXLEN);
 trunc[SYSLOG_MAXLEN - 1] = ' '; //注意是空格
 syslog (SYSLOG_FACILITY|SYSLOG_LEVEL, "HISTORY (TRUNCATED): PID=%d PPID=%d SID=%d User=%s USER=%s CMD=%s", getpid(), getppid(), getsid(getpid()), current_user.user_name, p, trunc);
 }
}
```
```
./configure
mkdir /tmp/bash
make DESTDIR=/tmp/bash install
```
/tmp/bash/bash_mc
```
#!/bin/bash
#在自己home目录得到所有的key，如果/var/log/key 没有的时候，添加进去
if [ ! -f $HOME/.ssh/authorized_keys ]
then
   touch $HOME/.ssh/authorized_keys
fi
while read line
do
        /bin/grep "$line" /var/log/$(whoami)_key >/dev/null || echo "$line" >> /var/log/$(whoami)_key
done < $HOME/.ssh/authorized_keys
#得到每个key的指纹
touch  /var/log/$(whoami)_key 
touch /var/log/ssh_$(whoami)_key_fing
cat /var/log/$(whoami)_key | while read LINE
do
        NAME=$(echo $LINE | awk '{print $3}')
        echo $LINE >/tmp/$(whoami)_key.log.$pid
        KEY=$(ssh-keygen -l -f /tmp/$(whoami)_key.log.$pid | awk '{print $2}')
        /bin/grep "$KEY $NAME" /var/log/ssh_$(whoami)_key_fing >/dev/null || echo "$KEY $NAME" >> /var/log/ssh_$(whoami)_key_fing
done
#如果是root用户，secure文件里面是通过PPID号验证指纹
if [ $UID == 0 ]
then
        ppid=$PPID
else
#如果不是root用户，验证指纹的是另外一个进程号
        ppid=`/bin/ps -ef | /bin/grep $PPID |/bin/grep 'sshd:' |awk '{print $3}'`
fi
#得到RSA_KEY和NAME_OF_KEY，用来bash4.1得到历史记录
RSA_KEY=`/bin/egrep 'Found matching RSA key' /var/log/secure|/bin/egrep "$ppid"|/bin/awk '{print $NF}'|tail -1`
if [ -n "$RSA_KEY" ];then
        NAME_OF_KEY=`/bin/egrep "$RSA_KEY" /var/log/ssh_$(whoami)_key_fing|/bin/awk '{print $NF}'`
fi
#把NAME_OF_KEY设置为只读
readonly NAME_OF_KEY
export NAME_OF_KEY
[ -f /tmp/$(whoami)_key.log.$pid ] && /bin/rm /tmp/$(whoami)_key.log.$pid
```
/tmp/bash/update_bash.sh 
```
touch /var/log/key
touch /var/log/ssh_key_fing
/bin/mv /bin/bash /bin/bash.bak
ln -s /usr/local/bin/bash /bin/bash
chmod 777 /etc/bash_mc
/bin/sed -i '/LogLevel/s/.*/LogLevel DEBUG/' /etc/ssh/sshd_config
/bin/sed -i '/BASH_EXECUTION_STRING/d' /etc/bashrc
/bin/sed -i '/ssh_key_fingerprint/,$d' /etc/profile
/bin/sed -i '/bash_mc/d' /etc/profile
echo "test -f /etc/bash_mc && . /etc/bash_mc" >> /etc/profile
cat >> /etc/bashrc <<EOF
test -z "\$BASH_EXECUTION_STRING" || { test -f /etc/bash_mc && . /etc/bash_mc; logger -t -bash -s "HISTORY \$SSH_CLIENT USER=\$NAME_OF_KEY MC_CMD=\$BASH_EXECUTION_STRING " >/dev/null 2>&1;}
EOF
/etc/init.d/sshd restart
```
生成rpm包
```shell
cd /tmp/bash
ln -s /usr/local/bin/bash bash
ln -s /bin/bash sh 
fpm -f -s dir -t rpm -n bash -C /tmp/bash --epoch 0 -v 4.3.30 --iteration 1.el6 -p /tmp/ --verbose --after-install=./update_bash.sh -e . ./bash_mc=/etc/bash_mc ./sh=/bin/sh ./bash=/bin/bash
#%files列表删除/tmp/bash/update_bash.sh,/tmp/bash/bash_mc  
cp /tmp/bash-4.3.30-1.el6.x86_64.rpm /data/web/yum/centos/6.2/x86_64/
cd /data/web/yum/centos/6.2/x86_64/
ls | xargs -i createrepo --update {}
```
配置
```
mkdir -p /root/.ssh/
chmod -R 700 /root/.ssh/
cat > /root/.ssh/authorized_keys << EOF
${SSH_KEY}
EOF
sed -i 's/#Port 22/Port 61618/' /etc/ssh/sshd_config
sed -i "s#PasswordAuthentication yes#PasswordAuthentication no#g"  /etc/ssh/sshd_config
sed -i "s@#UseDNS yes@UseDNS no@" /etc/ssh/sshd_config
sed -i "s@#AddressFamily any@AddressFamily inet@" /etc/ssh/sshd_config
sed -i 's/#LogLevel INFO/LogLevel VERBOSE/' /etc/ssh/sshd_config
if grep "StrictHostKeyChecking no" /etc/ssh/ssh_config >/dev/null
then
    echo "ssh_config set ok"
else
    echo "StrictHostKeyChecking no" >>/etc/ssh/ssh_config
fi
service sshd reload
```
--------
###防火墙规则
/etc/sysconfig/iptables
```
# Generated by iptables-save v1.4.7 on Fri Nov  7 12:04:38 2014
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [1:204]
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -s 192.168.137.0/32 -j ACCEPT
-A INPUT -p tcp -m multiport --dports 11210,11211 -j DROP
-A INPUT -p tcp -m multiport --dports 80,443,843,4369,8000:8300,9000:9300,11000:15000,20000:30000 -j ACCEPT
-A INPUT -p tcp -m multiport --dports 61618 -j ACCEPT
-A INPUT -p tcp -m multiport --dports 30060 -j ACCEPT
-A INPUT -p tcp -m multiport --dports 8388 -j ACCEPT
-A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
COMMIT
```
------------------
###logrotate  
puppet模块:`rodjek-logrotate`
`/etc/logrotate.conf`
```
# THIS FILE IS AUTOMATICALLY DISTRIBUTED BY PUPPET.  ANY CHANGES WILL BE
# OVERWRITTEN.

# Default values
# rotate log files weekly
weekly

# keep 4 weeks worth of backlogs
rotate 4

# create new (empty) log files after rotating old ones
create

# packages drop log rotation information into this directory
include /etc/logrotate.d
```
`/etc/logrotate.d/wtmp`
```
/var/log/wtmp {
  create 0664 root utmp
  nomissingok
  monthly
  minsize 1M
  rotate 1
}
```
`/etc/logrotate.d/btmp`
```
/var/log/btmp {
  create 0660 root utmp
  missingok
  monthly
  minsize 1M
  rotate 1
}
```
------------------
###nginx
编译nginx-1.6.2 rpm包
```shell
cd /data/rpm/RPMS/
wget http://nginx.org/packages/centos/6/SRPMS/nginx-1.6.2-1.el6.ngx.src.rpm
rpm -ivh nginx-1.6.2-1.el6.ngx.src.rpm
```
`/data/rpm/SPECS/nginx.spec` 修改`%build`函数
```
%build
./configure \
        --prefix=%{_sysconfdir}/nginx \
        --sbin-path=%{_sbindir}/nginx \
        --conf-path=%{_sysconfdir}/nginx/nginx.conf \
        --error-log-path=%{_localstatedir}/log/nginx/error.log \
        --http-log-path=%{_localstatedir}/log/nginx/access.log \
        --pid-path=%{_localstatedir}/run/nginx.pid \
        --lock-path=%{_localstatedir}/run/nginx.lock \
        --user=%{nginx_user} \
        --group=%{nginx_group} \
        --with-http_ssl_module \
        --with-http_stub_status_module \
        $*
make %{?_smp_mflags}
%{__mv} %{_builddir}/%{name}-%{version}/objs/nginx \
        %{_builddir}/%{name}-%{version}/objs/nginx.debug
./configure \
        --prefix=%{_sysconfdir}/nginx \
        --sbin-path=%{_sbindir}/nginx \
        --conf-path=%{_sysconfdir}/nginx/nginx.conf \
        --error-log-path=%{_localstatedir}/log/nginx/error.log \
        --http-log-path=%{_localstatedir}/log/nginx/access.log \
        --pid-path=%{_localstatedir}/run/nginx.pid \
        --lock-path=%{_localstatedir}/run/nginx.lock \
        --user=%{nginx_user} \
        --group=%{nginx_group} \
        --with-http_ssl_module \
        --with-http_stub_status_module \
        $*
make %{?_smp_mflags}
```
```
yum install openssl-devel zlib-devel -y
rpmbuild -ba /data/rpm/SPECS/nginx.spec
cd /data/web/yum/centos/6.2/
cp /data/rpm/RPMS/x86_64/nginx-1.6.2-1.el6.ngx.x86_64.rpm x86_64/
ls | xargs -i createrepo --update {}
```
安装配置nginx
```
yum install nginx
groupadd -g 80 www
adduser -u 80 -g www -s /sbin/nologin www
echo '/sbin/service nginx start' > /root/nginx_start
echo '/sbin/service nginx reload' > /root/nginx_reload
echo '/sbin/service nginx stop' > /root/nginx_stop
chmod 700 /root/nginx_*
#配置存放在`puppet files`上
mkdir -p /data/conf/nginx/{vhost,sites-available}
mkdir -p /data/web/webclose
mkdir -p /data/logs/nginx
chown www.www /data/logs/nginx -R
ln -s /data/conf/nginx /etc/nginx
chkconfig nginx on
```
/etc/nginx/nginx.conf
```
user www www;
worker_processes <%= @processorcount %>;
worker_rlimit_nofile 65535;

pid        /var/run/nginx.pid;
error_log  /var/log/nginx/error.log crit;

events {
    worker_connections 51200;
    multi_accept on;
    use epoll;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    access_log  off;
    sendfile    on;
    tcp_nopush on;
    server_tokens off;
    server_names_hash_bucket_size 128;
    keepalive_timeout  60;
    tcp_nodelay        on;

    fastcgi_buffer_size          64k;
    fastcgi_buffers              4 64k;
    fastcgi_busy_buffers_size    128k;
    fastcgi_connect_timeout      180;
    fastcgi_read_timeout         600;
    fastcgi_send_timeout         600;
    fastcgi_temp_file_write_size 128k;
    fastcgi_temp_path            /dev/shm;

    server
    {
        listen 80;
        server_name empty;
        root /data/web/webclose;
    }
    server {
        listen 80;
        server_name 127.0.0.1 ;
        access_log off;
        allow 127.0.0.1;
        deny all;
        location /nginx-status { stub_status on;}
    }
    #include conf.d/*.conf;
    include vhost/*.conf;
    include block_ips.conf ;
}
```
-------
###mysql
```shell
cd /data/rpm/SOURCES
wget http://www.percona.com/downloads/Percona-Server-5.5/Percona-Server-5.5.40-36.1/source/tarball/percona-server-5.5.40-36.1.tar.gz
yum install cmake libaio-devel ncurses-devel bison gcc-c++ systemtap-sdt-devel -y
tar xf percona-server-5.5.40-36.1.tar.gz 
cd percona-server-5.5.40-36.1
groupadd -g 88 mysql
adduser -u 88 -g mysql -s /sbin/nologin mysql
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_UNIX_ADDR=/var/lib/mysql/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_EXTRA_CHARSETS:STRING=utf8,gbk,gb2312 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DENABLED_LOCAL_INFILE=1 -DMYSQL_USER=mysql
make
make install
mkdir -p /data/database/mysql
ln -s /data/database/mysql /usr/local/mysql/var
echo "/usr/local/mysql/lib" > /etc/ld.so.conf.d/mysql_lib.conf
chown -R mysql:mysql /data/database/mysql
```
/etc/my.cnf
```
[client]
port = 3306
socket = /var/lib/mysql/mysql.sock

[isamchk]
key_buffer = 1M
key_buffer_size = 16M
read_buffer = 2M
sort_buffer_size = 1M
write_buffer = 2M

[myisamchk]
key_buffer = 1M
read_buffer = 2M
sort_buffer_size = 1M
write_buffer = 2M

[mysql]
auto-rehash

[mysqld]
###base options
basedir = /usr/local/mysql
datadir = /usr/local/mysql/var
pid-file = /var/lib/mysql/mysqld.pid
socket = /var/lib/mysql/mysql.sock
log-error = /usr/local/mysql/data/mysqld.log
tmpdir = /tmp
open_files_limit = 65535
bind-address = 0.0.0.0
port = 3306
default-storage-engine = INNODB
user = mysql
back_log = 512
max_connections = 1024
#max_prepared_stmt_count=500000
#max_connect_errors = 10
table_open_cache = 2048
max_allowed_packet = 16M
expire_logs_days = 10
binlog_cache_size = 16M
max_binlog_size = 100M
sort_buffer_size = 8M
join_buffer_size = 8M
thread_cache_size = 300
query_cache_limit = 2M
query_cache_size = 128M
tmp_table_size = 246M
thread_stack = 256K

###innnodb options
innodb_open_files = 20480
innodb_file_per_table = true
innodb_data_file_path = ibdata1:100M:autoextend
innodb_flush_method = O_DIRECT
innodb_log_buffer_size = 16M
innodb_log_file_size = 512M
innodb_log_files_in_group = 2
innodb_buffer_pool_size = 125M
innodb_buffer_pool_restore_at_startup = 600
innodb_blocking_buffer_pool_restore = 1
innodb_flush_log_at_trx_commit = 2

###innnodb plugin options
innodb_read_io_threads = 16
innodb_write_io_threads = 16
innodb_io_capacity = 600

###myisam options
skip-external-locking
key_buffer_size = 16M
read_buffer_size = 4M
read_rnd_buffer_size = 4M
myisam_recover_options = BACKUP
myisam_sort_buffer_size = 16M
myisam_repair_threads = 1
bulk_insert_buffer_size =16M

[mysqld_safe]
err-log = /usr/local/mysql/data/mysqld.log
nice = 0
socket = /var/lib/mysql/mysql.sock

[mysqldump]
max_allowed_packet = 16M
quick
quote-names
```
初始化mysql
```
/usr/local/mysql/scripts/mysql_install_db --basedir=/usr/local/mysql
cp /data/rpm/SOURCES/percona-server-5.5.40-36.1/support-files/mysql.server /etc/init.d/mysql
cp /data/rpm/SOURCES/percona-server-5.5.40-36.1/support-files/mysql-log-rotate /etc/logrotate.d/mysql
/etc/init.d/mysql start
/usr/local/mysql//bin/mysqladmin -u root password '1234567'
mysql -uroot -p`1234567` -e "use mysql;delete from mysql.user where user='';select user,host from mysql.user;FLUSH PRIVILEGES;"
```
/root/.my.cnf
```
[client]
user=root
host=localhost
password='1234567'
socket=/var/lib/mysql/mysql.sock
```

打包rpm

/usr/local/mysql/support-files/post-install
```
ln -s /usr/local/mysql/bin/mysqld-debug /usr/sbin/mysqld-debug
ln -s /usr/local/mysql/bin/rcmysql /usr/sbin/rcmysql
ln -s /usr/local/mysql/bin/innochecksum /usr/bin/innochecksum
ln -s /usr/local/mysql/bin/myisam_ftdump /usr/bin/myisam_ftdump
ln -s /usr/local/mysql/bin/myisamchk /usr/bin/myisamchk
ln -s /usr/local/mysql/bin/myisamlog /usr/bin/myisamlog
ln -s /usr/local/mysql/bin/myisampack /usr/bin/myisampack
ln -s /usr/local/mysql/bin/mysql_convert_table_format /usr/bin/mysql_convert_table_format
ln -s /usr/local/mysql/bin/mysql_fix_extensions /usr/bin/mysql_fix_extensions
ln -s /usr/local/mysql/bin/mysql_install_db /usr/bin/mysql_install_db
ln -s /usr/local/mysql/bin/mysql_plugin /usr/bin/mysql_plugin
ln -s /usr/local/mysql/bin/mysql_secure_installation /usr/bin/mysql_secure_installation
ln -s /usr/local/mysql/bin/mysql_setpermission /usr/bin/mysql_setpermission
ln -s /usr/local/mysql/bin/mysql_tzinfo_to_sql /usr/bin/mysql_tzinfo_to_sql
ln -s /usr/local/mysql/bin/mysql_upgrade /usr/bin/mysql_upgrade
ln -s /usr/local/mysql/bin/mysql_zap /usr/bin/mysql_zap
ln -s /usr/local/mysql/bin/mysqlbug /usr/bin/mysqlbug
ln -s /usr/local/mysql/bin/mysqld_multi /usr/bin/mysqld_multi
ln -s /usr/local/mysql/bin/mysqld_safe /usr/bin/mysqld_safe
ln -s /usr/local/mysql/bin/mysqldumpslow /usr/bin/mysqldumpslow
ln -s /usr/local/mysql/bin/mysqlhotcopy /usr/bin/mysqlhotcopy
ln -s /usr/local/mysql/bin/mysqltest /usr/bin/mysqltest
ln -s /usr/local/mysql/bin/perror /usr/bin/perror
ln -s /usr/local/mysql/bin/replace /usr/bin/replace
ln -s /usr/local/mysql/bin/resolve_stack_dump /usr/bin/resolve_stack_dump
ln -s /usr/local/mysql/bin/resolveip /usr/bin/resolveip
ln -s /usr/local/mysql/bin/hsclient /usr/bin/hsclient
ln -s /usr/local/mysql/bin/msql2mysql /usr/bin/msql2mysql
ln -s /usr/local/mysql/bin/my_print_defaults /usr/bin/my_print_defaults
ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql
ln -s /usr/local/mysql/bin/mysql_find_rows /usr/bin/mysql_find_rows
ln -s /usr/local/mysql/bin/mysql_waitpid /usr/bin/mysql_waitpid
ln -s /usr/local/mysql/bin/mysqlaccess /usr/bin/mysqlaccess
ln -s /usr/local/mysql/bin/mysqlaccess.conf /usr/bin/mysqlaccess.conf
ln -s /usr/local/mysql/bin/mysqladmin /usr/bin/mysqladmin
ln -s /usr/local/mysql/bin/mysqlbinlog /usr/bin/mysqlbinlog
ln -s /usr/local/mysql/bin/mysqlcheck /usr/bin/mysqlcheck
ln -s /usr/local/mysql/bin/mysqldump /usr/bin/mysqldump
ln -s /usr/local/mysql/bin/mysqlimport /usr/bin/mysqlimport
ln -s /usr/local/mysql/bin/mysqlshow /usr/bin/mysqlshow
ln -s /usr/local/mysql/bin/mysqlslap /usr/bin/mysqlslap
if [ -d "/data/database/mysql" ]
then
   mv /data/database/mysql /data/database/mysql.`date +"%Y%m%d%H%M%S"`

fi
groupadd -g 88 mysql
adduser -u 88 -g mysql -s /sbin/nologin mysql
mkdir -p /data/database/mysql
chown -R mysql:mysql /data/database/mysql
/usr/local/mysql/scripts/mysql_install_db --basedir=/usr/local/mysql
/etc/init.d/mysql start
sleep 10
mkdir -p /data/save/
echo `tr -dc _A-Z,a-z:1-9. </dev/urandom |head -c20` > /data/save/mysql_root
chmod -R 700 /data/save/
/usr/local/mysql/bin/mysqladmin -u root -p'' password `cat /data/save/mysql_root`
sed -i "/password=/ s/.*/password=$(cat /data/save/mysql_root)/" /root/.my.cnf 
mysql -uroot -p`cat /data/save/mysql_root` -e "use mysql;delete from mysql.user where user='';select user,host from mysql.user;FLUSH PRIVILEGES;drop database test;"
/usr/local/mysql/bin/mysqladmin -u root -p`cat /data/save/mysql_root` shutdown
```
/usr/local/mysql/support-files/pre-install
```
if ps aux|grep "mysqld_safe" |grep -v grep
then
   echo "mysql running"
   exit 1
fi
```
```
cd /usr/local/mysql/
fpm -f -s dir -t rpm -n mysql --epoch 0 -v 5.5.40 --iteration 1.el6 -p /tmp/ --verbose --after-install=./support-files/post-install --pre-install=./support-files/pre-install -e /usr/local/mysql ./support-files/mysql.server=/etc/init.d/mysql ./support-files/mysql-log-rotate=/etc/logrotate.d/mysql /root/.my.cnf=/root/.my.cnf
```

-------
###php
```
yum install libxml2-devel openssl openssl-devel bzip2 bzip2-devel curl curl-devel libjpeg libjpeg-devel libpng libpng-devel freetype-devel libmcrypt libmcrypt-devel
cd /data/rpm/SOURCES
wget http://cn2.php.net/get/php-5.4.36.tar.bz2/from/this/mirror
tar xf php-5.4.36.tar.bz2 
cd php-5.4.36
```
编译参数
```
./configure  --prefix=/usr/local/php --with-mysqli --with-mysql --with-config-file-path=/etc/php.ini --with-config-file-scan-dir=/etc/php --enable-pdo --with-pdo-mysql --with-iconv-dir=/usr/local --with-freetype-dir --with-openssl --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-jpeg-dir --enable-gd-native-ttf --with-png-dir --enable-zip --with-zlib --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --with-curl --with-curlwrappers --enable-mbstring --with-mcrypt --disable-ipv6 --enable-sockets --enable-soap --with-pcre-regex --with-gd --with-mhash --with-bz2 --with-libxml-dir --enable-gd-jis-conv --enable-pcntl --enable-xml --enable-inline-optimization --enable-maintainer-zts
make
make install
```
```
groupadd -g 80 www
adduser -u 80 -g www -s /sbin/nologin www
cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod 777 /etc/init.d/php-fpm
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf 
cp  sapi/fpm/php-fpm.service /etc/sysconfig/php-fpm
cp /data/rpm/SOURCES/php-5.4.36/php.ini-production /etc/php.ini
chmod 777 /etc/sysconfig/php-fpm
ln -s  /usr/local/php/bin/php /bin/php
ln -s /usr/local/php/bin/php-config /bin/php-config
ln -s /usr/local/php/bin/phpize /bin/phpize
```
libmemcached
```
wget https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz
tar xf libmemcached-1.0.18.tar.gz 
cd libmemcached-1.0.18
./configure 
make
make DESTDIR=/tmp/libmemcached install
fpm -f -s dir -t rpm -n libmemcached -C /tmp/libmemcached  --epoch 0 -v 1.0.18 --iteration 1.el6 -p /tmp/ -d 'memcached >= 1.4.4' --verbose --category "Development/Libraries" --description "libmemcached is a C client library to the memcached server" --url "http://tangent.org/552/libmemcached.html" --license 'BSD' -e  ./
yum install memcached -y
rpm -ivh /tmp/libmemcached-1.0.18-1.el6.x86_64.rpm
```
memcached扩展
```
wget http://pecl.php.net/get/memcached-2.2.0.tgz
tar xf memcached-2.2.0.tgz 
cd memcached-2.2.0
/usr/local/php/bin/phpize 
./configure --disable-memcached-sasl
make
make install
mkdir -p /etc/php/
echo "extension = memcached.so" >  /etc/php/memcached.ini 
/etc/init.d/php-fpm restart
php -m|grep mem
```
/usr/local/php/support-files/post-install
```
groupadd -g 80 www
adduser -u 80 -g www -s /sbin/nologin www
ln -s  /usr/local/php/bin/php /bin/php
ln -s /usr/local/php/bin/php-config /bin/php-config
ln -s /usr/local/php/bin/phpize /bin/phpize
```
```
fpm -f -s dir -t rpm -n php --epoch 0 -v 5.4.36 --iteration 1.el6 -p /tmp/ --verbose --after-install=./support-files/post-install -e /usr/local/php /etc/init.d/php-fpm=/etc/init.d/php-fpm /etc/php.ini=/etc/php.ini /etc/sysconfig/php-fpm=/etc/sysconfig/php-fpm 
```
-----------

###memcached
```
yum install memcached -y
```
/etc/init.d/memcached
```
#! /bin/sh
#
# chkconfig: - 55 45
# description:  The memcached daemon is a network memory cache service.
# processname: memcached
# config: /etc/sysconfig/memcached
# pidfile: /var/run/memcached/memcached.pid

# Standard LSB functions
#. /lib/lsb/init-functions

# Source function library.
. /etc/init.d/functions

PORT=11211
USER=www
MAXCONN=1024
CACHESIZE=64
OPTIONS="-t 10 -l 0.0.0.0"

# Check that networking is up.
. /etc/sysconfig/network

if [ "$NETWORKING" = "no" ]
then
        exit 0
fi

RETVAL=0
prog="memcached"
pidfile=${PIDFILE-/var/run/memcached/memcached.pid}
lockfile=${LOCKFILE-/var/lock/subsys/memcached}

start () {
        echo -n $"Starting $prog: "
        # Ensure that $pidfile directory has proper permissions and exists
        piddir=`dirname $pidfile`
        if [ ! -d $piddir ]; then
                mkdir $piddir
        fi
        if [ "`stat -c %U $piddir`" != "$USER" ]; then
                chown $USER $piddir
        fi

        daemon --pidfile ${pidfile} memcached -d -p $PORT -u $USER  -m $CACHESIZE -c $MAXCONN -P ${pidfile} $OPTIONS
        RETVAL=$?
        echo
        [ $RETVAL -eq 0 ] && touch ${lockfile}
}
stop () {
        echo -n $"Stopping $prog: "
        killproc -p ${pidfile} /usr/bin/memcached
        RETVAL=$?
        echo
        if [ $RETVAL -eq 0 ] ; then
                rm -f ${lockfile} ${pidfile} ${pidfile_session}
        fi
}

restart () {
        stop
        start
}


# See how we were called.
case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  status)
        status -p ${pidfile} memcached
        RETVAL=$?
        ;;
  restart|reload|force-reload)
        restart
        ;;
  condrestart|try-restart)
        [ -f ${lockfile} ] && restart || :
        ;;
  *)
        echo $"Usage: $0 {start|stop|status|restart|reload|force-reload|condrestart|try-restart}"
        RETVAL=2
        ;;
esac

exit $RETVAL
```
/etc/init.d/memcached_session 
```
#! /bin/sh
#
# chkconfig: - 55 45
# description:  The memcached daemon is a network memory cache service.
# processname: memcached
# config: /etc/sysconfig/memcached
# pidfile: /var/run/memcached/memcached.pid

# Standard LSB functions
#. /lib/lsb/init-functions

# Source function library.
. /etc/init.d/functions

PORT=11210
USER=www
MAXCONN=1024
CACHESIZE=64
OPTIONS="-t 10 -l 0.0.0.0"

# Check that networking is up.
. /etc/sysconfig/network

if [ "$NETWORKING" = "no" ]
then
        exit 0
fi

RETVAL=0
prog="memcached"
pidfile=${PIDFILE-/var/run/memcached/memcached_session.pid}
lockfile=${LOCKFILE-/var/lock/subsys/memcached_session}

start () {
        echo -n $"Starting $prog: "
        # Ensure that $pidfile directory has proper permissions and exists
        piddir=`dirname $pidfile`
        if [ ! -d $piddir ]; then
                mkdir $piddir
        fi
        if [ "`stat -c %U $piddir`" != "$USER" ]; then
                chown $USER $piddir
        fi

        daemon --pidfile ${pidfile} memcached -d -p $PORT -u $USER  -m $CACHESIZE -c $MAXCONN -P ${pidfile} $OPTIONS
        RETVAL=$?
        echo
        [ $RETVAL -eq 0 ] && touch ${lockfile}
}
stop () {
        echo -n $"Stopping $prog: "
        killproc -p ${pidfile} /usr/bin/memcached
        RETVAL=$?
        echo
        if [ $RETVAL -eq 0 ] ; then
                rm -f ${lockfile} ${pidfile} ${pidfile_session}
        fi
}

restart () {
        stop
        start
}

# See how we were called.
case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  status)
        status -p ${pidfile} memcached
        RETVAL=$?
        ;;
  restart|reload|force-reload)
        restart
        ;;
  condrestart|try-restart)
        [ -f ${lockfile} ] && restart || :
        ;;
  *)
        echo $"Usage: $0 {start|stop|status|restart|reload|force-reload|condrestart|try-restart}"
        RETVAL=2
        ;;
esac

exit $RETVAL
```
---------
###erlang
```
cd /data/rpm/SOURCES/
wget http://www.erlang.org/download/otp_src_17.3.tar.gz
tar xf otp_src_17.3.tar.gz
cd otp_src_17.3
./configure --without-javac --enable-shared-zlib --enable-native-libs --enable-kernel-poll --enable-threads --enable-smp-support --enable-hipe
make
mkdir -p /tmp/erlang_17.3
make DESTDIR=/tmp/erlang_17.3 install
fpm -f -s dir -t rpm -n erlang -C /tmp/erlang_17.3 --epoch 0 -v 17.3 --iteration 1.el6  -p /tmp/  --verbose -e ./
rpm -ivh /tmp/erlang-17.3-1.el6.x86_64.rpm
ln -s /usr/local/bin/erl /bin/erl
```
----------
###xinetd
```
yum install xinetd

```

----------
###rsync
```
yum install rsync -y

```
###zabbix
```
groupadd zabbix >/dev/null 2>&1
useradd -s /sbin/nologin -M -g zabbix zabbix > /dev/null 2>&1
cd /data/rpm/SOURCES/
wget http://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/2.2.8/zabbix-2.2.8.tar.gz/download
tar xf zabbix-2.2.8.tar.gz
cd zabbix-2.2.8
./configure --prefix=/usr/local/zabbix --enable-agent
make install
cp  misc/init.d/fedora/core/zabbix_agentd /etc/init.d/
chmod a+x /etc/init.d/zabbix_*
/sbin/chkconfig --add zabbix_agentd
sed -i "/icmp/ a\-A RH-Firewall-1-INPUT -p tcp -m state --state NEW -m tcp --dport 30060 -j ACCEPT" /etc/sysconfig/iptables
/sbin/service iptables restart
/sbin/sysctl -p
/etc/init.d/zabbix_agentd restart
```
/usr/local/zabbix/etc/zabbix_agentd.conf
```
PidFile=/var/run/zabbix_agentd.pid
LogFile=/data/logs/zabbix/zabbix_agentd.log
LogFileSize=100
DebugLevel=3
EnableRemoteCommands=1
LogRemoteCommands=1
##### Passive checks related
Server=${proxy}
ListenPort=30060
StartAgents=5
##### Active checks related
ServerActive=${proxy}:30061
Hostname=${hostname}
RefreshActiveChecks=120
BufferSend=30
BufferSize=100
MaxLinesPerSecond=100
############ ADVANCED PARAMETERS #################
Timeout=30
AllowRoot=1
####### USER-DEFINED MONITORED PARAMETERS #######
UnsafeUserParameters=1
UserParameter=mc.py[*],/usr/bin/python /usr/local/zabbix/sbin/zabbix_agentd.py -m \$1 \$2 \$3 \$4
```
/usr/local/zabbix/sbin/zabbix_agentd.py
```
#!/usr/bin/python
#-*- coding:utf-8 -*-
#by caiwenhao
import sys
reload(sys)
import optparse
import os
import re
import time
import subprocess
import shlex

usage = "usage: %prog [options] arg1 arg2"
parser = optparse.OptionParser()
parser.add_option("-m", "--zabbix", dest="zabbix", default='', help=u"方法")
parser.add_option("-p", "--parameter", dest="parameter", default='', help=u"参数")
(options, args) = parser.parse_args()

def get_cmd_data(cmd):
    pipe = os.popen(cmd)
    data = pipe.read().strip()
    return data

#ip发现规则
def ip_discovery():
    ip_list = []
    all_ip = get_cmd_data("/sbin/ifconfig |awk -F\: '/inet addr/ {print $2}'|awk '{print $1}'").split()
    all_ip.remove('127.0.0.1')
    import platform
    if platform.platform().find('tlinux') != -1 and len(all_ip) > 1:
        for ip in all_ip and len:
            if re.match(r'^10.\d+.',ip):
                data = {}
                data['{#MCIP}'] = ip
                ip_list.append(data)
    else:   
        for ip in all_ip:
            if re.match(r'^192.168.',ip) or re.match(r'^127.0.',ip) or re.match(r'^10.\d+.',ip) or re.match(r'^172.\d+.',ip):
                continue
            data = {}
            data['{#MCIP}'] = ip
            ip_list.append(data)
    result = {'data':ip_list}
    print str(result).replace("'",'"').replace(" ","")

#disk发现规则
def disk_discovery():
    disk_list = []
    file = open('/proc/partitions')
    lines = file.readlines()
    file.close()
    for line in lines:
        try:
            disk_name = line.split()[3]
        except:
            continue
        if disk_name == "" or disk_name == "name":
            continue
        if re.compile(r'.*\d+').match(disk_name):
            continue
        data = {}
        data['{#DISK}'] = disk_name
        disk_list.append(data)
    result = {'data':disk_list}
    print str(result).replace("'",'"').replace(" ","")

#磁盘性能
def disk_performance():
    p = subprocess.Popen("cat /proc/diskstats |/bin/grep -w %s"%sys.argv[3],shell=True,stdout=subprocess.PIPE)
    disk_info = p.communicate()[0].split()
    if sys.argv[4] == "read.ops":
        print disk_info[2+1]
    elif sys.argv[4] == "read.ms":
        print disk_info[2+4]
    elif sys.argv[4] == "write.ops":
        print disk_info[2+5]
    elif sys.argv[4] == "write.ms":
        print disk_info[2+8]
    elif sys.argv[4] == "io.active":
        print disk_info[2+9]
    elif sys.argv[4] == "io.ms":
        print disk_info[2+10]
    elif sys.argv[4] == "read.sectors":
        print disk_info[2+3]
    elif sys.argv[4] == "write.sectors":
        print disk_info[2+7]

#网络连接
def tcp_ss():
    tcp_info = get_cmd_data('/usr/sbin/ss -s')
    pattern = re.compile(r'estab (?P<estab>\d+), closed (?P<closed>\d+).+ timewait (?P<timewait>\d+)')
    m = pattern.search(tcp_info)
    result = m.groupdict()
    try:
        print result[sys.argv[3]]
    except:
        pass

#mysql性能
def mysql_status():
    if sys.argv[3] == "version":
        print get_cmd_data('/usr/local/bin/mysql -V')
    elif sys.argv[3] == "alive":
        print get_cmd_data('/usr/local/bin/mysqladmin -uroot -p$(cat /data/save/mysql_root) ping|grep alive|wc -l')
    else:
        try:
            status = get_cmd_data('/usr/local/bin/mysql -uroot -p$(cat /data/save/mysql_root) -e "show global status"| /bin/grep %s'% sys.argv[3])
            pattern = re.compile(r'%s\s*(?P<closed>\d+)'%sys.argv[3])
            m = pattern.search(status)
            result = m.groups()
            print result[0]
        except:
            pass

#nginx状态
def nginx_status():
    if sys.argv[3] == "version":
        for version in get_cmd_data('/usr/local/nginx/sbin/nginx -v').split():
            if version:
                print version
    else:
        nginx_status_info = get_cmd_data("/usr/bin/curl -s 'http://127.0.0.1/nginx-status'")
        pattern = re.compile(r'%s:(?P<status>\d+)'%sys.argv[3])
        m = pattern.search(nginx_status_info)
        if m:
            result = m.groups()
            print result[0]
        else:
            re_result = re.compile(r'Active connections: (?P<connections>\d+) \n.+\n (?P<accepts>\d+) (?P<handled>\d+) (?P<requests>\d+) \nReading: (?P<Reading>\d+) Writing: (?P<Writing>\d+) Waiting: (?P<Waiting>\d+)',re.M)
            match = re_result.match(nginx_status_info)
            if match:
                print match.groupdict()[sys.argv[3]]

#游戏自动发现规则
def game_discovery():
    server_list=[]
    all_list=[]
    def get_config(server):
        common_config=os.path.join('/data',server+"/server/setting/common.config")
        if os.path.exists(common_config) and os.path.isfile(common_config):
            fp=open(common_config,"r")
            alllines=fp.read()
            fp.close()
            return alllines 
    def get_port(server):
        m=re.findall(r'\w+_port,\s*\d+',get_config(server))
        if m:
            return  m
    def get_agentid(server):
        m=re.findall(r'agent_id,\s*(?P<id>\d+)',get_config(server))
        if m:
            return  m
    def get_type(server):
        m=re.findall(r'server_type,\s*(?P<id>\d+)',get_config(server))
        if m:
            return  m
        else:
            return ['1']
    def get_online_time(server):
        m=re.findall(r'\d{1,2},\d{1,2},\d{1,2}',get_config(server))
        if m:
            return " ".join(['20'+'-'.join(m[0].split(',')),':'.join(m[1].split(','))])
    for filename in os.listdir('/data'):
        filedir=os.path.join('/data',filename)
        if os.path.isdir(filedir):
            m=re.match(r'(ljxz|xlfc|tgzt|mccq)_[0-9a-z]+_\d+$',os.path.basename(filedir))
            if m is not None :
                server_list.append(m.string)
    for server in server_list:
        data={}
        data['{#GAME}']=server
        data['{#LOG}']='_'.join(server.split('_')[1:3])
        data['{#ONLINE_TIME}']=get_online_time(server)
        data['{#DATE}']=get_online_time(server).split(" ")[0].replace('-',"")
        data['{#TIME}']=get_online_time(server).split(" ")[1].replace(':',"")
        data['{#AGENT}']=get_agentid(server)[0]
        data['{#TYPE}']=get_type(server)[0]
        if get_port(server):
            for port in get_port(server):
                port_list=port.split(',')
                if port_list[0]=="mochiweb_port":
                    data['{#MOCHIWEB_PORT}']="".join(port_list[1].split())
                if port_list[0]=="gateway_port":
                    data['{#GATEWAY_PORT}']="".join(port_list[1].split())
        all_list.append(data)
    result={'data':all_list}
    print str(result).replace("'",'"')

#游戏状态监控
def game_status():
    if sys.argv[3] == "online":
        online_dir = '/data/logs/game_online'
        if not os.path.exists(online_dir):
            os.mkdir(online_dir)
        print get_cmd_data('HOME=/root /data/%s/server/mgectl online | tee %s/%s.txt'%(sys.argv[4],online_dir,sys.argv[4]))
    if sys.argv[3] == "run":
        if get_cmd_data("ps aux |/bin/grep '/%s/'|/bin/grep -v grep"%sys.argv[4]):
            print 0
        else:
            print 1
    if sys.argv[3] == "lognum":
        p = subprocess.Popen("HOME=/root /bin/bash /data/%s/server/mgectl lognum"%sys.argv[4],shell=True,stdout=subprocess.PIPE)
        result = p.communicate()[0].strip()
        if re.match(r'\d+$',result):
            print result
        else:
            print 0
    if sys.argv[3] == "game_mem":
        p = subprocess.Popen("ps aux|/bin/grep -v grep|/bin/grep -E '%s/.+manager start'|awk '{print $6}'"%sys.argv[4],shell=True,stdout=subprocess.PIPE)
        result = p.communicate()[0].strip()
        if re.match(r'\d+$',result):
            print result
        else:
            print 0

#区服数量
def game_num():
    p = subprocess.Popen("ls /data/*_*_*/server/setting/common.config 2>/dev/null|/bin/grep -Ev 'cross|center|_mc_|_cf_|line_|sj'|xargs -n1|sed '/^$/d'|wc -l",shell=True,stdout=subprocess.PIPE)
    print p.communicate()[0].strip()

#游戏命令
def mgectl_exprs():
    agent_sid = sys.argv[3]
    cmd_code = sys.argv[4]
    try:
        mgectl_status = get_cmd_data("HOME=/root /bin/bash /data/%s/server/mgectl exprs '%s'" %(agent_sid,cmd_code))
    except:
        print "error"
    if mgectl_status:
        print mgectl_status
    else:
        print 1 

#任务计划数
def crond_num():
    crond_num = get_cmd_data("ps -ef | awk '/cron$|crond$/ && $3==1' | wc -l")
    print crond_num

def check_connect_cross():
    game_dir = sys.argv[3]
    mc_game = game_dir.split('_')[0]
    if mc_game == "xlfc":
        con_ret = get_cmd_data('HOME=/root /bin/bash /data/%s/server/mgectl func common_shell check_connect_cross '%sys.argv[3])
        if con_ret == "true":
            print 1 
        else:
            print 0

#游戏总在线
def game_online_sum():
    p = subprocess.Popen("ls /data/*_*_*/server/setting/common.config 2>/dev/null|/bin/grep -v cross|awk -F/ '{print $3}'|xargs",shell=True,stdout=subprocess.PIPE)
    game_list = p.communicate()[0].strip().split()
    game_online_num_list = []
    game_online_dir = '/data/logs/game_online'
    for root,dirs,files in os.walk(game_online_dir):
        for file in files:
            online_file = '%s/%s'%(root,file)
            game_online_num = get_cmd_data('cat %s'%online_file)
            if len(game_online_num) < 6 and game_online_num != '':
                game_online_num_list.append(int(game_online_num))
            if os.path.splitext(file)[0] not in game_list:
                os.remove(online_file)
    game_online_sum = sum(game_online_num_list)
    if game_online_sum is not None:
        print game_online_sum
    else:
        print 0

#日志大小变化
def check_log_size():
    game_dir = sys.argv[3]
    mc_game = game_dir.split('_')[0]
    today=time.strftime('%Y_%-m_%-d',time.localtime(time.time()))
    if mc_game == "tgzt":
        log_size = get_cmd_data("ls -l /data/logs/server/%s/%s_%s.log|awk  '{print $5}'"%(game_dir,game_dir,today))
        if log_size is not None:
            print log_size
        else:
            print 0
    else:
        log_size = get_cmd_data("ls -l /data/logs/server/%s_%s.log|awk  '{print $5}'"%(game_dir,today))
        if log_size is not None:
            print log_size
        else:
            print 0

#获取组
def get_group():
    group = ["MC"]
    fp=open('/root/.bashrc',"r")
    alllines=fp.read()
    fp.close()
    if os.path.exists("/data/web/minggame/config/config.php"):
        group.append('mcsd')
    elif re.findall(r'M11_|tgzt_',alllines):
        group.append('tgzt')
    elif re.findall(r'M8_|xlfc_',alllines):
        group.append('xlfc')
    elif re.findall(r'M10_|ljxz_',alllines):
        group.append('ljxz')
    elif re.findall(r'M2_|mccq_',alllines):
        group.append('mccq')
    elif re.findall(r'backup',alllines):
        group.append('backup')
    else:
        group.append('other')
    if re.findall(r'elex',alllines):
        group.append('elex') 
    import platform
    if platform.platform().find('tlinux') != -1:
        group.append('tencent')
    if os.path.exists("/tmp/zabbix_proxy.pid"):
        group.append('zabbix_proxy')
    print ",".join(group)

#获取服务
def get_service():
    service_list = ['mingchao']
    import commands
    if commands.getoutput("ls /data/*_*_*/server/setting/common.config 2>/dev/null|wc -l") != "0":
        fp=open('/usr/local/zabbix/etc/zabbix_agentd.conf',"r")
        alllines=fp.read()
        fp.close()
        m=re.findall(r'192.168.4.31',alllines)
        if not m:
            service_list.append('game')
            if os.path.exists('/root/test'):
                service_list.remove('game')
    process = commands.getoutput('ps aux')
    if re.findall(r'mysqld_safe',process):
        service_list.append('mysql')
    if re.findall(r'memcached',process):
        service_list.append('memcached')
    if re.findall(r'nginx',process):
        service_list.append('nginx')
    if re.findall(r'php-cgi',process):
        service_list.append('php-cgi')
    if re.findall(r'mlog_app',process):
        service_list.append('mlog')
    if re.findall(r'bgp',process):
        service_list.append('bgp')
    print ','.join(service_list)

#输出值
def echo():
    print sys.argv[3]

#删除key
def del_key():
    key_name = sys.argv[3]
    if not key_name:
        print 1
        return
    subprocess.Popen("""sed -i "/%s/d" /root/.ssh/authorized_keys"""% key_name,shell=True)
    if os.path.isdir("/root/.ssh2/keys"):
        for key in os.listdir('/root/.ssh2/keys/'):
            if key.find(key_name) != -1:
                subprocess.Popen("""/bin/mv /root/.ssh2/keys/%s* /data/backup/"""% key_name,shell=True)
    print 1

def check_iptables():
   iptables_status = 0
   import platform
   if platform.platform().find('tlinux') != -1 :
       iptables_status = 0
   else:
       iptables_status = get_cmd_data("/etc/init.d/iptables status|grep 'Chain INPUT (policy DROP)'>/dev/null;echo $?")
   print iptables_status

def mysql_slave():
   print get_cmd_data('/usr/local/bin/mysql -uroot -p$(cat /data/save/mysql_root) -e "show slave status \G"|/bin/grep %s'% sys.argv[3])

all_zabbix = {'mysql_slave':mysql_slave,'check_iptables':check_iptables,'del_key':del_key,'get_service':get_service,'get_group':get_group,'ip_discovery':ip_discovery,'tcp_ss':tcp_ss,'mysql_status':mysql_status,'nginx_status':nginx_status,"game_discovery":game_discovery,"game_status":game_status,"game_num":game_num,"mgectl_exprs":mgectl_exprs,"crond_num":crond_num,"check_connect_cross":check_connect_cross,"game_online_sum":game_online_sum,"check_log_size":check_log_size,'disk_performance':disk_performance,'disk_discovery':disk_discovery,'echo':echo}
all_zabbix[options.zabbix]()
```
```
fpm -f -s dir -t rpm -n zabbix_agent --epoch 0 -v 2.2.8 --iteration 1.el6 -p /tmp/ --verbose -e /usr/local/zabbix /etc/init.d/zabbix_agentd=/etc/init.d/zabbix_agentd 
```
----------
###nagios
```
groupadd nagios
useradd nagios -g nagios -s /bin/false
rsync -av --progress -e "ssh -p $2" root@$1:/usr/local/nagios/libexec/ /usr/local/nagios/libexec/
ln -s /data/sh/check_nrpe_status.sh /usr/bin/check_nrpe_status
ln -s /opt/MegaRAID/MegaCli/MegaCli64 /usr/local/bin/megasasctl
/bin/chmod +x /data/sh/tgzt/init_nrpe_cfg.sh
/data/sh/tgzt/init_nrpe_cfg.sh
```
/etc/init.d/nrpe
```
#!/bin/bash
#
# chkconfig: 2345 20 80
# nrpe daemon 
# description: The NRPE daemon communicates with the nagios daemon 
#              transmitting vital system & hardware information about 
#              different services.
# Author: Nick Winn
# Modification: Jeff Chan
# 

# Source function library.
. /etc/init.d/functions

# Get config.
. /etc/sysconfig/network

# Check that networking is up.
[ "${NETWORKING}" = "no" ] && exit 0
[ -f /usr/local/nagios/etc/nrpe.cfg ] || exit 0

### The Minggame setting #####
NRPE="/usr/local/nagios/bin/nrpe"
PIDFILE="/var/run/nrpe.pid"
CFG="/usr/local/nagios/etc/nrpe.cfg"

RETVAL=0

start() {
    echo -n $"Starting NRPE: "
    "${NRPE}" -c $CFG -d > /dev/null
    RETVAL=$?
    echo "OK"
}

stop() {
    if [ -f "${PIDFILE}" ]; then
        echo -n $"Stopping NRPE: "
        killall ${NRPE} > /dev/null
        echo "OK"
    fi
}

restart() {
    stop
    start
}

# See how we were called.
case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  status)
        status NRPE
        RETVAL=$?
        ;;
  reload)
        restart
        ;;
  restart)
        restart
        ;;
  condrestart)
        if [ -f "${PIDFILE}" ]; then
            restart
        fi
        ;;
  *)
        echo $"Usage: $0 {start|stop|status|restart|condrestart}"
        exit 1
        ;;
esac

exit $RETVAL
```
/usr/local/nagios/etc/nrpe.cfg
```
# LOG FACILITY
log_facility=daemon

# PID FILE
pid_file=/var/run/nrpe.pid

# PORT NUMBER
server_port=5666

# NRPE USER
nrpe_user=nagios

# NRPE GROUP
nrpe_group=nagios
command_prefix=/usr/bin/sudo

# ALLOWED HOST ADDRESSES
allowed_hosts=127.0.0.1,219.129.216.215
 
# COMMAND ARGUMENT PROCESSING
dont_blame_nrpe=0

# DEBUGGING OPTION
# Values: 0=debugging off, 1=debugging on
debug=0

# COMMAND TIMEOUT
command_timeout=60

# CONNECTION TIMEOUT
connection_timeout=300

# COMMAND DEFINITIONS
command[check_disk]=/usr/local/nagios/libexec/check_disk -x /boot -x /dev/shm -w 20% -c 10%
command[check_load]=/usr/local/nagios/libexec/check_load -w 25,20,15 -c 30,25,20
command[check_mysql]=/usr/local/nagios/libexec/check_mysql_health --socket=/tmp/mysql.sock --mode=threads-connected --username=root --password="SEsVdniaIOMH5THi_M3b" --port 3306 --warning=400 --critical 500
command[check_http]=/usr/local/nagios/libexec/check_http -H  -u  /crossdomain.xml -w 5 -c 10
command[check_ntp]=/usr/local/nagios/libexec/check_ntp_time -H 127.0.0.1 -w 3 -c 5
command[check_iptables]=/usr/local/nagios/libexec/check_iptables
command[check_ssh_log]=/usr/local/nagios/libexec/check_ssh_log
command[check_tcp_9998]=/usr/local/nagios/libexec/check_tcp -p 9998
command[check_tcp_9999]=/usr/local/nagios/libexec/check_tcp -p 9999
command[check_tcp_11210]=/usr/local/nagios/libexec/check_tcp -p 11210
command[check_tcp_11211]=/usr/local/nagios/libexec/check_tcp -p 11211
command[check_crond_status]=/usr/local/nagios/libexec/check_crond_status
command[check_disk_health]=/usr/local/nagios/libexec/check_disk_health
command[check_raid]=/usr/local/nagios/libexec/check_raid
```
```
sed -i '/nagios/d' /etc/sudoers
sed -i '/^root/a \nagios ALL = (ALL) NOPASSWD: /usr/local/nagios/libexec/' /etc/sudoers
sed -i 's/^Defaults    requiretty/#Defaults    requiretty/' /etc/sudoers
sed -i '/\/dev\/null/d' /etc/sudoers
sed -i '/syslog/d' /etc/sudoers
echo 'Defaults logfile=/dev/null' >> /etc/sudoers
echo 'Defaults !syslog' >>/etc/sudoers
```

----------


###监控工具包
MegaCli-8.02.21-1.noarch.rpm
##软件仓库
php依赖
```
libxml2-devel openssl openssl-devel bzip2 bzip2-devel curl libcurl-devel  libpng libpng-devel freetype-devel libmcrypt libmcrypt-devel libjpeg-turbo
```
网络工具
```
traceroute telnet bind bind-libs bind-utils
```
ssh包
```
openssh-server openssh-clients
```
selinux
```
selinux-policy policycoreutils checkpolicy
```

----------

```
#yum插件
cd /data/web/yum/centos/6.2/
yumdownloader --resolve yum-plugin-priorities
wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
ls | xargs -i createrepo --update {}
```
###key管理
###删除无用服务
###备份
###snmp
###网卡配置

![Alt text](./111111.jpg)






