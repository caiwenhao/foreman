class erlang(
  $erlang_package = $::params::erlang_package,
)inherits ::params
{
  package { "$erlang_package":
    ensure         => installed,
    allow_virtual  => false,
    require        => Yumrepo['mcyw'],
  }
  file {"/bin/erl":
    ensure => link,
    target => "/usr/local/bin/erl",
    before => Package["$erlang_package"],
  }
  firewall { "4369 for erlang node":
    action => 'accept',
    dport  => "4369",
    proto  => 'tcp',
  }

}