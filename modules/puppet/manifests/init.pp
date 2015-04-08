class puppet(
  $puppet_server = $::params::puppet_server,
  $puppet_version = $::params::puppet_version,
) inherits ::params
{
  package { "puppet":
    ensure         => "$puppet_version",
    allow_virtual  => false,
    require        => Yumrepo['mcyw'],
  }
  file { "puppet.conf":
    content => template('puppet/puppet.erb'),
    path    => "/etc/puppet/puppet.conf",
    require => Package["puppet"],
    notify  => Service['zabbix_agentd']
  }
  service { 'puppet':
    ensure     => "running",
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => File['puppet.conf'],
  }
  logrotate::rule { 'puppet':
    rotate       => 5,
    path         => "/var/log/puppet/*log",
    missingok    => true,
    create_owner => 'puppet',
    create_group => 'puppet',
    create_mode  => '0644',
    sharedscripts => true,
    create        => true,
    ifempty      => false,
    rotate_every  => 'daily',
    postrotate   => "pkill -USR2 -u puppet -f 'puppet master' || true\n    [ -e /etc/init.d/puppet ] && /etc/init.d/puppet reload > /dev/null 2>&1 || true",
  }
}