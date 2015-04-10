class centos_env::firewall(){
  firewallchain { 'INPUT:filter:IPv4':
    policy => 'drop',
  }
  firewallchain { 'FORWARD:filter:IPv4':
    policy => 'drop',
  }
  firewallchain { 'OUTPUT:filter:IPv4':
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
  firewall { "8000:8300 for game_gateway":
    action => 'accept',
    dport  => "8000-8300",
    proto  => 'tcp',
  }
  firewall { "9000:9300 for game_mochiweb":
    action => 'accept',
    dport  => "9000-9300",
    proto  => 'tcp',
  }
  firewall { "20000:30000 for mlog":
    action => 'accept',
    dport  => "20000-30000",
    proto  => 'tcp',
  }
  firewall { "843 for flash":
    action => 'accept',
    dport  => "843",
    proto  => 'tcp',
  }
  firewall { "443 for game":
    action => 'accept',
    dport  => "443",
    proto  => 'tcp',
  }

}

