class puppet(
  $puppet_package = $::params::puppet_package,
  $puppet_server = $::params::puppet_server,
) inherits ::params
{
  package { "$puppet_package":
    ensure         => installed,
    allow_virtual  => false,
    require        => Yumrepo['mcyw'],
  }
  file { "puppet.conf":
    content => template('puppet/puppet.erb'),
    path    => "/etc/puppet/puppet.conf",
    require => Package["$puppet_package"],
    notify  => Service['zabbix_agentd']
  }
  service { 'puppet':
    ensure     => "running",
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => File['puppet.conf'],
  }
}