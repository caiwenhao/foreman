class params::static {
  centos_env::lib::mkdir_p { "/data/sh/static": }
  file {"/data/sh/static":
    ensure  => directory,
    require =>  Centos_env::Lib::Mkdir_p["/data/sh/static"],
  }
  file {"remove_old_static.py":
    source => "puppet:///modules/params/static/remove_old_static.py",
    mode => '755',
    path => "/data/sh/static/remove_old_static.py",
    require => File['/data/sh/static']
  }
  cron { "remove_old_static":
    command => "/usr/local/bin/python2.7 /data/sh/static/remove_old_static.py> /dev/null 2>&1",
    user    => root,
    hour    => 6,
    minute  => 41,
    require => Package["crontabs"];
  }
  file {"ljxz_rsync_static.sh":
    source => "puppet:///modules/params/static/ljxz_rsync_static.sh",
    mode => '755',
    path => "/data/sh/static/ljxz_rsync_static.sh",
    require => File['/data/sh/static']
  }
  file {"ljxz_qq_pic.sh":
    source => "puppet:///modules/params/static/ljxz_qq_pic.sh",
    mode => '755',
    path => "/data/sh/static/ljxz_qq_pic.sh",
    require => File['/data/sh/static']
  }
  cron { "ljxz_rsync_static":
    command => "/bin/bash /data/sh/static/ljxz_rsync_static.sh > /dev/null 2>&1",
    user    => root,
    require => Package["crontabs"],
  }
  cron { "ljxz_qq_pic":
    command => "/bin/bash /data/sh/static/ljxz_qq_pic.sh > /dev/null 2>&1",
    user    => root,
    require => Package["crontabs"],
    ensure => absent,
  }
}