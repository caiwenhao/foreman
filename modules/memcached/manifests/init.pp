class memcached(
  $memcached_package = $::params::memcached_package,
  $memcached_enable = $::params::memcached_enable,
) inherits ::params
{
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
  case $memcached_enable {
    true: { $ensure = 'running' }
    false: { $ensure = 'stopped ' }
  }
  service { 'memcached':
    ensure     => $ensure,
    enable     => $memcached_enable,
    hasstatus  => true,
    hasrestart => true,
    restart    => true,
    require    => File["memcached"],
  }
  service { 'memcached_session':
    ensure     => $ensure,
    enable     => $memcached_enable,
    hasstatus  => true,
    hasrestart => true,
    restart    => true,
    require    => File["memcached_session"],
  }

}