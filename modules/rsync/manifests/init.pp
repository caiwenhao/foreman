class rsync(
  $rsync_package = "rsync-3.0.6-12.el6.x86_64",
){
  package { "$rsync_package":
    ensure         => installed,
    allow_virtual  => false,
    require        => Yumrepo['mcyw'],
  }
  centos_env::lib::mkdir_p { "/data/conf/rsync": }
  file {"/data/conf/rsync":
    ensure  => directory,
    require =>  Centos_env::Lib::Mkdir_p["/data/conf/nginx"],
  }
  file {"rsyncd_conf":
    content => template('rsync/rsyncd.erb'),
    path => "/data/conf/rsync/rsyncd.conf",
    require => Package["$rsync_package"],
  }
  file {"rsyncd_motd":
    content => template('rsync/rsyncd.motd.erb'),
    path => "/data/conf/rsync/rsyncd.motd",
  }
  file {"rsyncd.secrets":
    content => template('rsync/rsyncd.secrets.erb'),
    path    => "/data/conf/rsync/rsyncd.secrets",
    mode    => '600',
  }
  file {"/etc/rsyncd.conf":
    ensure => link,
    target => "/data/conf/rsync/rsyncd.conf",
    require => File['/data/conf/rsync'],
  }
  file {"/etc/rsyncd.motd":
    ensure => link,
    target => "/data/conf/rsync/rsyncd.motd",
    require => File['/data/conf/rsync'],
  }
  file {"/etc/rsyncd.secrets":
    ensure => link,
    target => "/data/conf/rsync/rsyncd.secrets",
    require => File['/data/conf/rsync'],
  }
  firewall { '100 for Master_Backup':
    action  => 'accept',
    proto   => 'all',
    source  => '113.107.160.72',
  }
  include xinetd
  xinetd::service { 'rsync':
    bind        => '0.0.0.0',
    port        => '873',
    server      => '/usr/bin/rsync',
    server_args => "--daemon --config /etc/rsyncd.conf",
    require     => Package["$rsync_package"],
  }
}