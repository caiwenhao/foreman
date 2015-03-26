class msalt(
  #非定义参数
  $bashrc_ps1 = $::params::bashrc_ps1,
  #公共级别参数
  $token = $::params::msalt::token,
  $api_token = $::params::msalt::api_token,
  $log_url = $::params::msalt::log_url,
  $queue_url  = $::params::msalt::queue_url,
  $http_auth_token = $::params::msalt::http_auth_token,
  $http_permission_ip = $::params::msalt::http_permission_ip,
  #集群级别参数
  $master_ip = $::params::msalt::master_ip,
  $node_ip = $::params::msalt::node_ip,
  $msalt_version = $::params::msalt::msalt_version,
  $zk_servers = $::params::msalt::zk_servers,
  $zk_auth = $::params::msalt::zk_auth,
  $fs_host = $::params::msalt::fs_host,
  $fs_user = $::params::msalt::fs_user,
  $fs_pass = $::params::msalt::fs_pass,
  #代理级别参数
  $agent = $::params::msalt::agent,
  #机器级别参数
  $msalt_enable = $::params::msalt::msalt_enable,
) inherits ::params
{
  package { "msalt":
    ensure         => $msalt_version ,
    allow_virtual  => false,
    require        => Yumrepo['mcyw'],
  }
  file { '/usr/local/lib/python2.7/site-packages/msalt.pth':
    content => "/data/msalt\n/data/msalt/third_part\n",
    mode    => '700',
    require => package["python-2.7.9-1.el6.x86_64"],
  }
  file { '/etc/ld.so.conf.d/msalt_lib.conf':
    content => "/data/msalt/third_part/lib\n",
    mode    => '700',
  }
  centos_env::lib::mkdir_p { "/data/backup/msalt": }
  file {"/data/backup/msalt":
    ensure  => directory,
    require =>  Centos_env::Lib::Mkdir_p["/data/backup/msalt"],
  }
  centos_env::lib::mkdir_p { "/data/backup/msalt_copy": }
  file {"/data/backup/msalt_copy":
    ensure  => directory,
    require =>  Centos_env::Lib::Mkdir_p["/data/backup/msalt_copy"],
  }
  centos_env::lib::mkdir_p { "/data/logs/msalt": }
  file {"/data/logs/msalt":
    ensure  => directory,
    require =>  Centos_env::Lib::Mkdir_p["/data/logs/msalt"],
  }
  file {'/data/logs/msalt/msalt.log':
    ensure => file,
    require => File['/data/logs/msalt']
  }
  file {'/data/logs/msalt/msalt_http.log':
    ensure => file,
    require => File['/data/logs/msalt']
  }
  firewall { "61131 for msalt":
    action => 'accept',
    dport  => "61131",
    proto  => 'tcp',
    source => "$master_ip",
  }
  exec {"/sbin/ldconfig":
    refreshonly => true,
    path        => "/usr/bin:/usr/sbin:/bin",
    subscribe   => File['/etc/ld.so.conf.d/msalt_lib.conf'],
  }
  centos_env::lib::mkdir_p { "/data/msalt/var/backup": }
  file {"/data/msalt/var/backup/":
    ensure  => directory,
    require =>  Centos_env::Lib::Mkdir_p["/data/msalt/var/backup"],
  }
  centos_env::lib::mkdir_p { "/data/msalt/var/cache": }
  file {"/data/msalt/var/cache":
    ensure  => directory,
    require =>  Centos_env::Lib::Mkdir_p["/data/msalt/var/cache"],
  }
  centos_env::lib::mkdir_p { "/data/conf/msalt": }
  file {"/data/conf/msalt":
    ensure  => directory,
    require =>  Centos_env::Lib::Mkdir_p["/data/conf/msalt"],
  }
  file {"msalt.conf":
    content => template('msalt/msalt.conf.erb'),
    path    => "/data/conf/msalt/msalt.conf",
    mode    => '775',
    require => File["/data/conf/msalt"],
  }
  file {"msalt_httpd.conf":
    content => template('msalt/msalt_httpd.conf.erb'),
    path    => "/data/conf/msalt/msalt_httpd.conf",
    mode    => '775',
    require => File["/data/conf/msalt"],
  }
  file {"fs_services.conf":
    content => template('msalt/fs_services.conf.erb'),
    path    => "/data/conf/msalt/fs_services.conf",
    mode    => '775',
    require =>  File["/data/conf/msalt"],
  }
  file {"main.conf":
    content => template('msalt/main.conf.erb'),
    path    => "/data/msalt/conf/main.conf",
    mode    => '775',
    require =>  Package['msalt'],
  }
  file {"/etc/msalt":
    ensure => link,
    target => "/data/conf/msalt",
    force  => true,
    purge => true,
    require => File["msalt.conf","msalt_httpd.conf","fs_services.conf"],
  }
  case $msalt_enable {
    true: { $ensure = 'running' }
    false: { $ensure = 'stopped' }
  }
  service { 'msalt-common':
    ensure     => $ensure,
    enable     => $msalt_enable,
    hasstatus  => true,
    hasrestart => true,
    restart    => true,
    require    => File["/etc/msalt",'main.conf'],
  }
  service { 'msalt-httpd':
    ensure     => $ensure,
    enable     => $msalt_enable,
    hasstatus  => true,
    hasrestart => true,
    restart    => true,
    require    =>  File["/etc/msalt",'main.conf'],
  }
  logrotate::rule { 'msalt':
    path         => '/data/logs/msalt/*',
    rotate       => 14,
    rotate_every => 'daily',
    ifempty      => false,
    copytruncate => true,
    create       => true,
  }
}