class zabbix(
  $proxy_list = $::params::proxy_list,
  $zbbix_package = $::params::zbbix_package,
  $zabbix_center = $::params::zabbix_center,
  $listen_port = $::params::listen_port,
  $server_port = $::params::server_port,
  $bashrc_ps1 = $::params::bashrc_ps1,
)inherits ::params
{
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
  }
}