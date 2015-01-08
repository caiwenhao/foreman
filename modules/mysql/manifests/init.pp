class mysql(
  $mysql_package = "mysql-5.5.40-1.el6.x86_64"
){
  file { '/root/mysql_start':
    content => '/sbin/service mysql start',
    mode    => '700',
  }
  file { '/root/mysql_stop':
    content => '/sbin/service mysql stop',
    mode    => '700',
  }
  file { '/root/mysql_processlist':
    content => "mysql -uroot -p`cat /data/save/mysql_root` -e 'SHOW processlist;",
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
  service { 'mysql':
    ensure   => "running",
    name     => "mysql",
    enable   => true,
    require  => package["$mysql_package"],
  }
}