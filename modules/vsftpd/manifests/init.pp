class vsftpd (
  $vsftpd_version = "2.2.2-13.el6_6.1",
  $template  = 'vsftpd/vsftpd.conf.erb',
  $vsftpd_enable = false,
  $vsftpd_port = "11021",
  $vsftpd_user = [{name =>'mingchao_ljxz',passwd=>'n2lsyqt58a514TJT7bBB',path=> "/data/ljxz/web/static/1"},{name =>'mingchao_xlfc',passwd=>'n2lsyqt58a514TJT7bXX',path=> "/data/xlfc_mobile/web/static"}]
) {
  package { "vsftpd":
    ensure         => $vsftpd_version,
    allow_virtual  => false,
    require        => Yumrepo['mcyw'],
  }
  file { "vsftpd.conf":
    content => template('vsftpd/vsftpd.conf.erb'),
    path => "/etc/vsftpd/vsftpd.conf",
    require => Package["vsftpd"],
    notify => Service['vsftpd']
  }
  file{"/etc/vsftpd/chroot_list":
    content => "www",
    require => Package["vsftpd"],
  }
  file {"login_passwd":
    content => template('vsftpd/login_passwd.txt.erb'),
    path => "/etc/vsftpd/login_passwd.txt",
    require => Package["vsftpd"],
    notify => Exec['create_db'],
  }
  centos_env::lib::mkdir_p { "/etc/vsftpd/vuser_conf": }
  file {"/etc/vsftpd/vuser_conf":
    ensure  => directory,
    require =>  Centos_env::Lib::Mkdir_p["/etc/vsftpd/vuser_conf"],
  }
  define conifg_user( $path){
    file {$name:
      content => template('vsftpd/vuser_conf.erb'),
      path => "/etc/vsftpd/vuser_conf/$name",
      require => Package["vsftpd"],
    }
  }
  @conifg_user {"mingchao_ljxz":path => "/data/ljxz/web/static/1"}
  @conifg_user {"mingchao_xlfc":path => "/data/xlfc_mobile/web/static"}
  realize(Conifg_user['mingchao_ljxz'],Conifg_user['mingchao_xlfc'])
  case $vsftpd_enable {
    true: { $ensure = 'running' }
    false: { $ensure = 'stopped' }
  }
  file {"/etc/pam.d/vsftpd":
    content => template('vsftpd/pam.erb'),
    require => Package["vsftpd"],
  }
  exec {'create_db':
    command => "/usr/bin/db_load -T -t hash -f /etc/vsftpd/login_passwd.txt /etc/vsftpd/vuser_passwd.db",
    refreshonly => true,
  }
  service { 'vsftpd':
    ensure     => $ensure,
    enable     => $vsftpd_enable,
    hasstatus  => true,
    hasrestart => true,
    restart    => true,
    require    => File["vsftpd.conf"],
  }
}

