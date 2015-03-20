class params {
  #环境变量
  $bashrc_ps1 = get_ps1( "${::hostname}","${::ipaddress}","61618")
  $project_name = inline_template("<%= bashrc_ps1.split('_')[0] %>")

  #ntp配置

  #ssh配置
  $ssh_port = 61618
  $sshd_packages = "bash-4.3.30-4.el6.x86_64"
  $root_passwd = inline_template("<%= @ipaddress + 'mingchao' %>")

  #dns配置
  $nameservers = ['121.10.118.123','114.114.114.114','223.5.5.5','223.6.6.6','112.124.47.27','202.96.128.143','202.96.128.166','202.96.128.86']

  #erlang版本
  $erlang_package = "erlang-17.3-1.el6.x86_64"

  #memcached配置
  $memcached_package = "memcached-1.4.21-3.el6.art.x86_64"
  $memcached_enable = true

  #msalt配置
  $master_ip = "113.107.160.72"
  $msalt_package = 'msalt-3.2.0-1.el6.x86_64'

  #mysql配置
  $mysql_package = "mysql-5.5.40-1.el6.x86_64"
  $mysql_enable = true

  #nagios配置
  $nagios_package ="nagios-1.0.0-1.el6.x86_64"
  $nagios_server = "219.129.216.215"
  $nagios_port = 5666

  #nginx
  $nginx_package = "nginx-1.6.2-1.el6.ngx.x86_64"
  $nginx_enable = true

  #php
  $php_package = "php-5.4.36-1.el6.x86_64"
  $libmemcached_package ="libmemcached-1.0.18-1.el6.x86_64"
  $php_enable = true

  #puppet
  $puppet_package ="puppet-3.7.4-1.el6.noarch"
  $puppet_server ="foreman.mcyw.mingchaoonline.com"

  #rsync
  $rsync_package = "rsync-3.1.1-12.el6.x86_64"

  #zabbix
  $proxy_list = get_url("http://183.61.135.114:30062?ip=${wan_ip}&qq_projet=")
  $zbbix_package ="zabbix_agent-2.2.8-1.el6"
  $zabbix_center ="183.61.135.114,103.5.57.114"
  $listen_port = 30060
  $server_port = 30061
}