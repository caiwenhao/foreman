class erlang(
  $erlang_package = "erlang-17.3-1.el6.x86_64",
){
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

}