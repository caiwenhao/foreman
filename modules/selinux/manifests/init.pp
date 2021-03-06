# == Class: selinux
#
#  This class manages SELinux on RHEL based systems.
#
# === Parameters:
#  [*mode*]
#    (enforcing|permissive|disabled)
#    sets the operating state for SELinux.
#
#  [*installmake*]
#    make is required to install modules. If you have the make package declared
#    elsewhere, you want to set this to false. It defaults to true.
#
# === Requires:
#  - [puppetlab/stdlib]
#
# == Example
#
#  include selinux
#
class selinux(
  $mode         = 'disabled',
  $installmake  = true,
  ) {
  include selinux::params

  file { $selinux::params::modules_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0440',
  }

  class { 'selinux::config':
      mode => $mode,
  }
  if $mode == 'disabled' {
    exec { "setenforce 0;touch /var/tmp/selinux":
      path => '/bin:/sbin:/usr/bin:/usr/sbin',
      creates => '/var/tmp/selinux',
      require => Class[ 'selinux::config'],
    }
  }

}
