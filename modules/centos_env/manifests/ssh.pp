class centos_env::ssh(
  $ssh_port = "61618",
  $sshd_packages = "bash-4.3.30-1.el6.x86_64",
  $root_passwd = inline_template("<%= @ipaddress + 'mingchao' %>")
)
{
  case $::osfamily {
    'RedHat': {
      $packages                        = ['openssh-server', 'openssh-clients']
      $service_name                    = 'sshd'
      $ssh_config_hash_known_hosts     = 'no'
      $ssh_config_forward_x11_trusted  = 'yes'
      $ssh_sendenv                        = true
      $sshd_config_subsystem_sftp      = '/usr/libexec/openssh/sftp-server'
      $sshd_config_mode                  = '0600'
      $sshd_config_use_dns             = 'yes'
      $sshd_config_xauth_location      = '/usr/bin/xauth'
      $sshd_use_pam                    = 'yes'
      $sshd_gssapikeyexchange          = undef
      $sshd_pamauthenticationviakbdint = undef
      $sshd_gssapicleanupcredentials   = 'yes'
      $sshd_acceptenv                  = true
      $service_hasstatus               = true
      $sshd_config_serverkeybits       = '1024'
      $sshd_config_hostkey             = [ '/etc/ssh/ssh_host_rsa_key' ]
    }
    'Suse': {
      $packages                        = 'openssh'
      $service_name                    = 'sshd'
      $ssh_config_hash_known_hosts     = 'no'
      $ssh_sendenv                     = true
      $ssh_config_forward_x11_trusted  = 'yes'
      $sshd_config_mode                = '0600'
      $sshd_config_use_dns             = 'yes'
      $sshd_config_xauth_location      = '/usr/bin/xauth'
      $sshd_use_pam                    = 'yes'
      $sshd_gssapikeyexchange          = undef
      $sshd_pamauthenticationviakbdint = undef
      $sshd_gssapicleanupcredentials   = 'yes'
      $sshd_acceptenv                  = true
      $service_hasstatus               = true
      $sshd_config_serverkeybits       = '1024'
      $sshd_config_hostkey             = [ '/etc/ssh/ssh_host_rsa_key' ]
      case $::architecture {
        'x86_64': { $sshd_config_subsystem_sftp = '/usr/lib64/ssh/sftp-server'}
        'i386' : { $sshd_config_subsystem_sftp = '/usr/lib/ssh/sftp-server'}
      }
    }
    default: {
      fail("ssh supports osfamilies RedHat, Suse, Debian and Solaris. Detected osfamily is <${::osfamily}>.")
    }
  }
  package { ['openssh-server', 'openssh-clients']:
    ensure         => installed,
    allow_virtual  => false,
    require        => Yumrepo['mcyw'],
    before         => Exec['install_bash'],
  }
  file {"${sshd_packages}.rpm":
    source  => "puppet:///modules/centos_env/${sshd_packages}.rpm",
    path    => '/dist/dist/${sshd_packages}.rpm',
  }
  exec {'install_bash':
    command => "/bin/rpm -U /dist/dist/${sshd_packages}.rpm --force",
    path    => ["/usr/bin", "/usr/sbin"],
    unless => "/bin/rpm -qa |/bin/grep ${sshd_packages} 2>/dev/null",
    require => File["${sshd_packages}.rpm"],
  }
  augeas  { 'ssh_config' :
    context => "/files",
    changes => 'set /etc/ssh/ssh_config/Host/StrictHostKeyChecking "yes"',
    require => Package[$packages],
  }
  augeas  { 'sshd_config' :
    context => "/files/etc/ssh/sshd_config",
    changes => ["set Port ${ssh_port}","set PasswordAuthentication  no","set UseDNS no","set AddressFamily inet","set LogLevel DEBUG"],
    require => Package[$packages],
    notify => Service["sshd_service"],
  }
  centos_env::lib::mkdir_p { "${::root_home}/.ssh": }
  file { 'root_ssh_dir':
    ensure  => directory,
    path    => "${::root_home}/.ssh",
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    require => Centos_env::Lib::Mkdir_p["${::root_home}/.ssh"],
  }
  service { 'sshd_service' :
    ensure     => "running",
    name       => "sshd",
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package[$packages],
  }
  firewall { "$ssh_port for SSH":
    action => 'accept',
    dport  => "$ssh_port",
    proto  => 'tcp',
  }
  file {"/${::root_home}/.ssh/authorized_keys":
    content => template('centos_env/authorized_keys.erb'),
    require => File['root_ssh_dir'],
    mode    => '644',
  }
  user { "root":password => sha1(md5($root_passwd))}
}