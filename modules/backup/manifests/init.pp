class backup(
  $project_name = $::params::project_name,
) inherits ::params
{
  centos_env::lib::mkdir_p { "/data/sh/backup": }
  file {"/data/sh/backup":
    ensure  => directory,
    require =>  Centos_env::Lib::Mkdir_p["/data/sh/backup"],
  }
  file {"backup_all":
    content => template('backup/backup_all.erb'),
    path    => "/data/sh/backup/backup_all.sh",
    mode    => '775',
    require => File['/data/sh/backup'],
  }
  file {"backup_game":
    content => template('backup/backup_game.erb'),
    path    => "/data/sh/backup/backup_game.sh",
    mode    => '775',
    require => File['/data/sh/backup'],
  }
  file {"remove_log":
    content => template('backup/remove_log.erb'),
    path    => "/data/sh/backup/remove_old_log.sh",
    mode    => '775',
    require => File['/data/sh/backup'],
  }
  cron {backup_all:
    command =>"/bin/bash /data/sh/backup/backup_all.sh > /dev/null 2>&1",
    user    =>root,
    hour    =>6,
    minute  =>0,
    require =>Package["crontabs"];
  }
  cron {backup_game:
    command =>"/bin/bash /data/sh/backup/backup_game.sh > /dev/null 2>&1",
    user    =>root,
    hour    =>'*/3',
    minute  =>0,
    require =>Package["crontabs"];
  }
  cron {remove_log:
    command => "/bin/bash /data/sh/backup/remove_old_log.sh > /dev/null 2>&1",
    user    => root,
    weekday => 1,
    hour    => 1,
    minute  => 0,
    require => Package["crontabs"];
  }
  tidy { '/data/logs':
    age     => '5w',
    recurse =>  true,
    type    => 'ctime',
    path    => '/data/logs',
    backup  => false,
  }
  tidy { '/data/backup':
    age     => '10w',
    recurse =>  true,
    type    => 'ctime',
    path    => '/data/backup',
    backup  => false,
  }
  centos_env::lib::mkdir_p { "/data/logs/backup": }
  file {"/data/logs/backup":
    ensure  => directory,
    require =>  Centos_env::Lib::Mkdir_p["/data/logs/backup"],
  }

}