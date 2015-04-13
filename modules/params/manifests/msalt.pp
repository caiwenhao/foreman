class params::msalt {
#公共级别参数
  $token = 'halq0n1eH6NqoWj5gjA79/j+xebQ2LSQSsVC88YN0ix68tIC0rZAzd7OoeQmqLz2XFXkcL2cDZk='
  $api_token = '84dstWVxeoiOV3ymivAi'
  $log_url = 'http://192.168.8.203:9092'
  $queue_url  = 'http://192.168.8.203:9093'
  $http_auth_token = 'XXXXXX'
  $http_permission_ip = '192.168.XX.XX'
#集群级别参数
  $master_ip = '192.168.8.43'
  $node_ip = $ipaddress
  $msalt_version = "1.2.7-1.el6"
  $zk_servers = '192.168.8.190:60001,192.168.8.191:60001,192.168.8.205:60001'
  $zk_auth = 'mcyw:adArA1YlDFFcQUuz'
  $fs_host = '192.168.XX.XX'
  $fs_user = 'xxxxx'
  $fs_pass = 'xxxxxxx'
#代理级别参数
  $agent = 'txsj'
#机器级别参数
  $msalt_enable = true
}