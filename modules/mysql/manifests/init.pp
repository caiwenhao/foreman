class mysql(
  $mysql_package = $::params::mysql_package,
  $mysql_enable = $::params::mysql_enable,
) inherits ::params
{
  file { '/root/mysql_start':
    content => "/sbin/service mysql start\n",
    mode    => '700',
  }
  file { '/root/mysql_stop':
    content => "/sbin/service mysql stop\n",
    mode    => '700',
  }
  file { '/root/mysql_processlist':
    content => "mysql -uroot -p`cat /data/save/mysql_root` -e 'SHOW processlist;'\n",
    mode    => '700',
  }
  file { "mysql_cnf":
    content => template('mysql/my.cnf.erb'),
    path    => "/etc/my.cnf",
    mode    => '0644',
    before => Package["$mysql_package"],
  }
  package {$mysql_package:
    ensure         => installed,
    allow_virtual  => false,
    require        => Yumrepo['mcyw'],
  }
  case $mysql_enable {
    true: { $ensure = 'running' }
    false: { $ensure = 'stopped' }
  }
  service { 'mysql':
    ensure   => $ensure,
    name     => "mysql",
    enable   => $mysql_enable,
    require  => package["$mysql_package"],
  }
}