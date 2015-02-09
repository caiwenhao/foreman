class php(
  $php_package = "php-5.4.36-1.el6.x86_64",
  $libmemcached_package ="libmemcached-1.0.18-1.el6.x86_64",
  $php_enable = true,
  $php_com_package = [
    "libxml2-devel",
    "openssl",
    "openssl-devel",
    "bzip2",
    "bzip2-devel",
    "curl",
    "libcurl-devel",
    "libpng",
    "libpng-devel",
    "freetype-devel",
    "libmcrypt",
    "libmcrypt-devel",
    "libjpeg-turbo",
  ]
){
  package { "$libmemcached_package":
    ensure         => installed,
    allow_virtual  => false,
    require        => Yumrepo['mcyw'],
  }
  package { "$php_package":
    ensure         => installed,
    allow_virtual  => false,
    require        => Package["$libmemcached_package"],
  }
  file {"/root/fastcgi_restart":
    content => "/etc/init.d/php-fpm restart\n",
    mode    => '700',
  }
  file {"/root/fastcgi_start":
    content => "/etc/init.d/php-fpm start\n",
    mode    => '700',
  }
  file {"/etc/php":
    ensure => directory,
  }
  file {"php-fpm.conf":
    source  => "puppet:///modules/php/php-fpm.conf",
    require => Package[$php_package,$php_com_package],
    path    => '/usr/local/php/etc/php-fpm.conf',
    ensure  => file,
  }
  file {"php.ini":
    source  => "puppet:///modules/php/php.ini",
    path    => '/etc/php.ini',
    ensure  => file,
  }
  file {'memcached.ini':
    path => '/etc/php/memcached.ini',
    ensure  => file,
    content => "extension = memcached.so\n",
    require => File['/etc/php'],
  }
  case $php_enable {
    true: { $ensure = 'running' }
    false: { $ensure = 'stopped ' }
  }
  service { 'php-fpm':
    ensure     => $ensure,
    enable     => $php_enable,
    hasstatus  => true,
    hasrestart => true,
    restart => true,
    require => File["php-fpm.conf","php.ini",'memcached.ini'],
  }
}