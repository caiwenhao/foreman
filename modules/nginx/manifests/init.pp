class nginx(
  $nginx_package = "nginx-1.6.2-1.el6.ngx.x86_64"
){
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
    content => $service_reload,
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
  service { 'nginx':
    ensure     => "running",
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    restart => true,
    require => User['www'],

  }

}