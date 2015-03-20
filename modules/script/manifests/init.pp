class script(
  $project_name = $::params::project_name,
)inherits ::params
{
  centos_env::lib::mkdir_p { "/data/sh/game": }
  file {"/data/sh/game":
    ensure  => directory,
    require =>  Centos_env::Lib::Mkdir_p["/data/sh/game"],
  }
  file {"/data/sh/game/check_cache.sh":
    source  => "puppet:///modules/script/check_cache.sh",
    require => File['/data/sh/game'],
    mode    => '755',
  }
  file {"/root/game_start":
    content => template('script/game_start.erb'),
    mode    => '755',
  }
}