class nagios(
  $nagios_package = ["nagios-plugins","nrpe","nrpe-plugin"],
  $nagios_server =$::params::nagios_server,
  $nagios_port = $::params::nagios_port,
) inherits ::params
{
  package {'nagios':
    ensure => absent,
    allow_virtual  => false,
  }->
  package { $nagios_package:
    ensure         => installed,
    allow_virtual  => false,
    require        => Yumrepo['mcyw'],
  }
  user {"nagios":
    ensure => "present",
    shell  => "/sbin/nologin",
    groups => nagios,
  }
  group {"nagios":
    ensure => "present",
  }
  file {"/data/logs/nagios":
    ensure => directory,
    require => File['/data/logs']
  }
  file { "nrpe.cfg":
    content => template('nagios/nrpe.erb'),
    path    => "/usr/local/nagios/etc/nrpe.cfg",
    require => Package[$nagios_package],
  }
  file {'/etc/nagios/nrpe.cfg':
    ensure => link,
    target => "/usr/local/nagios/etc/nrpe.cfg",
    require => File['nrpe.cfg'],
  }
  file {'check_nrpe_status':
    path    => '/usr/bin/check_nrpe_status',
    content => template('nagios/check_nrpe_status'),
    mode    => 775,
    require => Package[$nagios_package],
  }
  file {'/etc/sudoers':
    owner  => "root",
    group  => "root",
    mode   => 0440,
    source => "puppet:///modules/nagios/sudoers",
    require => Package['sudo'],
  }
  firewall { "103 for nagios":
    action  => 'accept',
    proto   => 'all',
    source  => '219.129.216.215',
  }
  include xinetd
  xinetd::service { 'nrpe':
    bind        => '0.0.0.0',
    flags       => 'REUSE',
    socket_type => 'stream',
    wait        => 'wait',
    user        => 'nagios',
    group       => 'nagios',
    port        => '5666',
    server      => '/usr/sbin/nrpe',
    server_args => "-c /usr/local/nagios/etc/nrpe.cfg --inetd",
    disable     => 'no',
    only_from   => "127.0.0.1 $nagios_server",
    require     => Package[$nagios_package],
  }
}