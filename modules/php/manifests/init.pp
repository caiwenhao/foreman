class php(
  $php_version = $::params::php_version,
  $libmemcached_package = $::params::libmemcached_package,
  $php_enable = $::params::php_enable,
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
    "unixODBC-devel",
  ]
) inherits ::params
{
  package { "$libmemcached_package":
    ensure         => installed,
    allow_virtual  => false,
    require        => Yumrepo['mcyw'],
  }
  package { "php":
    ensure         => $php_version,
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
    require => Package["php",$php_com_package],
    path    => '/usr/local/php/etc/php-fpm.conf',
    ensure  => file,
  }
  file {"php.ini":
    source  => "puppet:///modules/php/php.ini",
    path => "/etc/php/php.ini",
    ensure  => file,
    require => File['/etc/php']
  }
  file {'memcached.ini':
    path => '/etc/php/memcached.ini',
    ensure  => file,
    content => "extension = memcached.so\n",
    require => File['/etc/php'],
  }
  file {"/etc/php.ini":
    ensure => link,
    target => "/etc/php/php.ini",
    require => File["/etc/php/php.ini"],
  }

  file {"php-fpm":
    source  => "puppet:///modules/php/php-fpm",
    path    => "/etc/init.d/php-fpm",
    mode    => '755',
    ensure  => file,
  }
  case $php_enable {
    true: { $ensure = 'running' }
    false: { $ensure = 'stopped' }
  }
  service { 'php-fpm':
    ensure     => $ensure,
    enable     => $php_enable,
    hasstatus  => true,
    hasrestart => true,
    restart    => true,
    require    => File["php-fpm.conf","php.ini",'memcached.ini',"php-fpm"],
  }
}