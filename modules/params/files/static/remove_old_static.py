#!/usr/bin/python
#-*- coding:utf-8 -*- 
__author__ = 'caiwenhao'

import sys,os
reload(sys)
sys.setdefaultencoding('utf8')
import urllib2
import re
import logging
import shutil

log_path='/data/logs/remove_old_static.log'
logger = logging.getLogger()
hdlr = logging.FileHandler(log_path)
formatter = logging.Formatter('%(asctime)s %(message)s')
hdlr.setFormatter(formatter)
logger.addHandler(hdlr)
logger.setLevel(logging.NOTSET)


keep_num = 15
project_static_info = []
project_static_info.append({"project":"ljxz","urls":["http://router0.app100666811.twsapp.com/yw_api/GetUseClientVersion.php"]})
project_static_info.append({"project":"xaxl","urls":["http://router1.app1101147160.twsapp.com/yw_api/GetUseClientVersion.php"]})
project_static_info.append({"project":"tgzt","urls":["http://web.tgzt.mingchaoonline.com/yw_api/GetUseClientVersion.php"]})
project_static_info.append({"project":"mccq","urls":["http://mccq1021.me4399.com/api/get_mccq_client_version.php"]})

def get_use_versions(info):
    version_list =[]
    for url in info['urls']:
        try:
            response = urllib2.urlopen(url)
	    result = response.read()
	    curr_version = list(set(result.split()))
            version_list.extend(curr_version)
        except:
            version_list = None
    return list(set(version_list))
	
for pro in project_static_info:
    static_path = "/data/%s/web/static"%pro['project']
    if not os.path.exists(static_path):
        continue
    all_version = [path for path in os.listdir(static_path) if re.match(r"\d{5,}$",path)]
    if len(all_version) <= keep_num:
	logger.debug("%s 当前前端个数少于15个"%pro['project'])
	continue
    curr_version = get_use_versions(pro)
    if not curr_version:
        logger.debug("%s 获取当前使用版本号失败"%pro['project'])
        continue
    rm_list = list(set(all_version)-set(curr_version))
    rm_num = len(rm_list)-(15 - len(curr_version))
    rm_list.sort()
    rm_list = rm_list[0:rm_num]
    for rm in rm_list:
        rm_path = os.path.join(static_path,rm)
        if rm == "":
            continue
        if os.path.exists(rm_path):
            #shutil.rmtree(rm_path) 
            logger.debug("%s 删除版本:%s 当前使用版本版本:%s"%(pro['project'],rm,' '.join(curr_version)))

	
