class nagios(
  $nagios_package = $::params::nagios_package,
  $nagios_server =$::params::nagios_server,
  $nagios_port = $::params::nagios_port,
) inherits ::params
{
  package { "$nagios_package":
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
    require => Package["$nagios_package"],
    notify  => Service['nrpe'],
  }
  file {"/usr/bin/check_nrpe_status":
    ensure => link,
    target => "/usr/local/nagios/bin/check_nrpe_status",
    require => Package["$nagios_package"],
  }
  file {'check_nrpe_status':
    path    => '/usr/local/nagios/bin/check_nrpe_status',
    content => template('nagios/check_nrpe_status'),
    mode    => 775,
    require => Package["$nagios_package"],
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
  service { 'nrpe':
    ensure     => "running",
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => File['nrpe.cfg'],
    path       => "/etc/init.d",
  }
}