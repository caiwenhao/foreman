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
