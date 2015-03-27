class tcollector(
  $tcollector_version = $::params::tcollector_version,
  $tcollector_server = $::params::tcollector_server,
  $project_name = $::params::project_name,
  $agent = $::params::agent,
  $role = $::params::role,
  $ipaddress = $::params::ipaddress,
  $tcollector_enable = $::params::tcollector_enable,
)inherits ::params
{
  package { "tcollector":
    ensure         => $tcollector_version,
    allow_virtual  => false,
    require        => Yumrepo['mcyw'],
  }
  file {"/usr/local/tcollector/collectors/0":
    ensure => directory,
    force  => true,
    purge => true,
    source  => "puppet:///modules/tcollector/0",
    recurse => true,
    require => Package['tcollector'],
  }
  file { "tsdb_collector":
    content => template('tcollector/tsdb_collector.erb'),
    path    => "/usr/local/tcollector/tsdb_collector",
    require => Package['tcollector'],
    notify  => Service['tsdb_collector'],
    mode    => '775',
  }
  file {"/etc/init.d/tsdb_collector":
    ensure => link,
    target => "/usr/local/tcollector/tsdb_collector",
    mode    => '775',
    require => File["tsdb_collector"],
  }
  case $tcollector_enable {
    true: { $ensure = 'running' }
    false: { $ensure = 'stopped' }
  }
  service { 'tsdb_collector':
    ensure     => $ensure,
    enable     => $tcollector_enable,
    hasstatus  => false,
    hasrestart => true,
    restart    => true,
    require    => File["tsdb_collector",'/usr/local/tcollector/collectors/0','/etc/init.d/tsdb_collector','/data/logs/tcollector'],
  }
  centos_env::lib::mkdir_p { "/data/logs/tcollector": }
  file {"/data/logs/tcollector":
    ensure  => directory,
    require =>  Centos_env::Lib::Mkdir_p["/data/logs/tcollector"],
  }
  logrotate::rule { 'tcollector':
    path         => '/data/logs/tcollector.log',
    rotate       => 14,
    olddir       => '/data/logs/tcollector',
    rotate_every => 'daily',
    ifempty      => false,
    copytruncate => true,
    create       => true,
    dateext      => true,
  }
}