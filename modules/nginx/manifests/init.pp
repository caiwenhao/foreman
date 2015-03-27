class nginx(
  $nginx_package =  $::params::nginx_package,
  $nginx_enable = $::params::nginx_enable,
) inherits ::params
{
  if $operatingsystem in ["CentOS"] {
    $service_start = '/sbin/service nginx start'
    $service_reload = '/sbin/service nginx reload'
    $service_stop = '/sbin/service nginx stop'
  }else{
    $service_start = '/etc/init.d/nginx start'
    $service_reload = '/etc/init.d/nginx reload'
    $service_stop = '/etc/init.d/nginx stop'
  }
  file {"/root/nginx_start":
    content => $service_start,
    mode    => '700',
  }
  file {"/root/nginx_reload":
    content => "/etc/init.d/nginx configtest\n$service_reload\n",
    mode    => '700',
  }
  file {"/root/nginx_stop":
    content => $service_stop,
    mode    => '700',
  }
  package { "nginx":
    name           => "$nginx_package",
    ensure         => installed,
    allow_virtual  => false,
    require        => Yumrepo['mcyw'],
    before         => File['/data/conf/nginx'],
  }
  centos_env::lib::mkdir_p { "/data/conf/nginx": }
  file {"/data/conf/nginx":
    source  => "puppet:///modules/nginx/",
    require => Centos_env::Lib::Mkdir_p["/data/conf/nginx"],
    purge => true,
    force  => true,
    recurse => true,
    ignore => ['vhost','nginx.conf','client_body_temp','scgi_temp','uwsgi_temp','proxy_temp'],
  }
  file {"/data/conf/nginx/vhost":
    ensure  => directory,
    require => File['/data/conf/nginx'],
  }
  centos_env::lib::mkdir_p { "/data/web/webclose": }
  file {"/data/web/webclose":
    require => Centos_env::Lib::Mkdir_p["/data/web/webclose"],
    ensure  => directory,
  }
  centos_env::lib::mkdir_p { "/data/logs/nginx": }
  file {"/data/logs/nginx":
    require => Centos_env::Lib::Mkdir_p["/data/logs/nginx"],
    ensure  => directory,
    owner => "www",
    group => "www",
  }
  file {"/etc/nginx":
    ensure => link,
    target => "/data/conf/nginx",
    force  => true,
    purge => true,
    require => File['/data/conf/nginx'],
  }
  file { "nginx_cnf":
    content => template('nginx/nginx.erb'),
    path => "/etc/nginx/nginx.conf",
    mode    => '0644',
    require => Package['nginx'],
    before  => Service['nginx'],
  }
  firewall { "80 for nginx":
    action => 'accept',
    dport  => "80",
    proto  => 'tcp',
  }
  case $nginx_enable {
    true: { $ensure = 'running' }
    false: { $ensure = 'stopped' }
  }
  service { 'nginx':
    ensure     => $ensure,
    enable     => $nginx_enable,
    hasstatus  => true,
    hasrestart => true,
    restart => true,
    require => User['www'],
  }
  logrotate::rule { 'nginx':
    path         => '/data/logs/nginx/*',
    rotate       => 14,
    rotate_every => 'daily',
    ifempty      => false,
    copytruncate => true,
    create       => true,
    dateext      => true,
  }

}