class zabbix(
  $proxy_list = inline_template("<%= `/usr/bin/curl -s 'http://183.61.135.114:30062?qq_projet='` %>"),
  $zbbix_package ="zabbix_agent-2.2.8-1.el6",
  $zabbix_center ="183.61.135.114,103.5.57.114",
  $zabbix_hostname = $centos_env::ps1,
  $listen_port = 30060,
  $server_port = 30061
){
  package { "$zbbix_package":
    ensure         => installed,
    allow_virtual  => false,
    require        => Yumrepo['mcyw'],
  }
  user {"zabbix":
    ensure => "present",
    shell  => "/sbin/nologin",
    groups => zabbix,
  }
  group {"zabbix":
    ensure => "present",
  }
  file {"/data/logs/zabbix":
    ensure => directory,
    require => File['/data/logs']
  }
  file { "zabbix_agentd.conf":
    content => template('zabbix/zabbix_agentd.erb'),
    path => "/usr/local/zabbix/etc/zabbix_agentd.conf",
    require => Package["$zbbix_package"],
    notify => Service['zabbix_agentd']
  }
  firewall { "$listen_port for zabbix_agentd":
    action => 'accept',
    dport  => "$listen_port",
    proto  => 'tcp',
  }
  file {"/usr/local/zabbix/sbin/zabbix_agentd.py":
    source  => "puppet:///modules/zabbix/zabbix_agentd.py",
    require => Package["$zbbix_package"],
    mode    => '775',
  }
  service { 'zabbix_agentd':
    ensure     => "running",
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => File['zabbix_agentd.conf'],
    path       => "/etc/init.d",
    provider   => init,
    restart    => "/etc/init.d/zabbix_agentd reload",
    start      => "/etc/init.d/zabbix_agentd start",
    stop       => "/etc/init.d/zabbix_agentd stop",
  }
}