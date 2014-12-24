define centos_env::lib::mkdir_p() {
  validate_absolute_path($name)
  exec { "mkdir_p-${name}":
    command => "mkdir -p ${name}",
    unless  => "test -d ${name}",
    path    => '/bin:/usr/bin',
  }
}