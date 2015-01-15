class nagios(
  $nagios_package ="nagios-1.0.0-1.el6.x86_64",
  $nagios_server = "219.129.216.215",
  $nagios_port = 5666
){
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
    before => Package["$nagios_package"],
  }
  file {'/etc/sudoers':
    owner  => "root",
    group  => "root",
    mode   => 0440,
    source => "puppet:///modules/nagios/sudoers",
    require => Package['sudo'],
  }
  firewall { "$nagios_port for nagios":
    action => 'accept',
    dport  => "$nagios_port",
    proto  => 'tcp',
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