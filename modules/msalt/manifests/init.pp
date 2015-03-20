class msalt(
  $master_ip = $::params::master_ip,
  $msalt_package = $::params::msalt_package,
  $project_name = $::params::project_name
) inherits ::params
{
  package { "$msalt_package":
    ensure         => installed,
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
  file {'/data/logs/msalt.log':
    ensure => file,
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
  file {"msalt.conf":
    content => template('msalt/msalt.erb'),
    path    => "/data/msalt/conf/msalt.conf",
    mode    => '775',
    require => Package["$msalt_package"],
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
}