class memcached(
  $memcached_package = "memcached-1.4.21-3.el6.art.x86_64",
){
  package { "$memcached_package":
    ensure         => installed,
    allow_virtual  => false,
    require        => Yumrepo['mcyw'],
  }
  file { "memcached":
    content => template('memcached/memcached.erb'),
    path    => "/etc/init.d/memcached",
    mode    => '755',
    require => Package["$memcached_package"],
  }
  file { "memcached_session":
    content => template('memcached/memcached_session.erb'),
    path    => "/etc/init.d/memcached_session",
    mode    => '755',
    require => Package["$memcached_package"],
  }
  file {"/root/memcached_start":
    content => "/etc/init.d/memcached start\n/etc/init.d/memcached_session start\n",
    mode    => '700',
  }
  file {"/root/memcached_stop":
    content => "/etc/init.d/memcached stop\n/etc/init.d/memcached_session stop\n",
    mode    => '700',
  }
  service { 'memcached':
    ensure     => "running",
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    restart    => true,
    require    => File["memcached"],
  }
  service { 'memcached_session':
    ensure     => "running",
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    restart    => true,
    require    => File["memcached_session"],
  }

}