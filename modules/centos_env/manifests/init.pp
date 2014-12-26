class centos_env(
  $ps1 = "cwh_puppet_agent_192.168.137.3_61618_A",
){
  include 'centos_env::sysctl'
  include 'centos_env::repo'
  include 'centos_env::firewall'
  include 'centos_env::ssh'
#设置终端环境语言
  augeas {"i18n" :
    context => "/files/etc/sysconfig/i18n",
    changes => [
      "set LANG '\"en_US.UTF-8\"'",
      "set SYSFONT '\"latarcyrheb-sun16\"'",]
  }
#bashrc配置
  file { "/root/.bashrc":
    ensure  => file,
    content => template("centos_env/bashrc.erb"),
  }
#bashrc配置
  file { "/root/.bash_profile":
    ensure  => file,
    content => template("centos_env/bash_profile.erb"),
  }
#创建必要的目录
  centos_env::lib::mkdir_p { "/data/database": }
  file {'database':
    ensure => directory,
    path    => "/data/database",
    require => Centos_env::Lib::Mkdir_p["/data/database"],
  }
  centos_env::lib::mkdir_p { "/data/logs": }
  file {'logs':
    ensure => directory,
    path    => "/data/logs",
    require => Centos_env::Lib::Mkdir_p["/data/logs"],
  }
  centos_env::lib::mkdir_p { "/data/backup/tmp": }
  file {'/data/backup/tmp':
    ensure => directory,
    path    => "/data/backup/tmp",
    require => Centos_env::Lib::Mkdir_p["/data/backup/tmp"],
  }
  centos_env::lib::mkdir_p { "/dist/dist/": }
  file {'/dist/dist/':
    ensure => directory,
    path    => "/dist/dist/",
    require => Centos_env::Lib::Mkdir_p["/dist/dist/"],
  }
  centos_env::lib::mkdir_p { "/dist/src/": }
  file {'/dist/src/':
    ensure => directory,
    path    => "/dist/src/",
    require => Centos_env::Lib::Mkdir_p["/dist/src/"],
  }
  centos_env::lib::mkdir_p { "/data/sh/": }
  file {'/data/sh/':
    ensure => directory,
    path    => "/data/sh/",
    require => Centos_env::Lib::Mkdir_p["/data/sh/"],
  }
}
