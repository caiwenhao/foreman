class centos_env::firewall(){
  resources { "firewall":purge => true}
  Firewall {
    require => undef,
  }
  firewallchain { 'INPUT:filter:IPv4':
    purge  => true,
    policy => 'drop',
  }
  firewallchain { 'FORWARD:filter:IPv4':
    purge  => true,
    policy => 'drop',
  }
  firewallchain { 'OUTPUT:filter:IPv4':
    purge  => true,
    policy => 'accept',
  }
  firewall { '001 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }->
  firewall { '002 accept related established rules':
    proto   => 'all',
    state => ['RELATED', 'ESTABLISHED'],
    action  => 'accept',
  }
  firewall { '999 accept all icmp':
    proto   => 'icmp',
    action  => 'accept',
  }
}

