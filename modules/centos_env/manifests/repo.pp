class centos_env::repo(){
  yumrepo { 'mcyw':
    baseurl        => "http://foreman.mcyw.mingchaoonline.com:8080/centos/6.2/x86_64",
    enabled        => "1",
    gpgcheck       => "0",
    descr          => "mcyw centos",
    priority       => "1"
  }
  package { ["yum-plugin-priorities"]:
    ensure         => installed,
    require        => Yumrepo["mcyw"],
    allow_virtual  => false,
  }
  $common_package = [
    "dos2unix",
    "libxml2-devel",
    "openssl",
    "openssl-devel",
    "bzip2",
    "bzip2-devel",
    "curl",
    "libcurl-devel",
    "libpng",
    "libpng-devel",
    "freetype-devel",
    "libmcrypt",
    "libmcrypt-devel",
    "libjpeg-turbo",
    "sudo",
    "crontabs",
    "glibc-2.12-1.149.el6_6.5",
    "glibc-common-2.12-1.149.el6_6.5",
    "glibc-devel-2.12-1.149.el6_6.5",
    "glibc-headers-2.12-1.149.el6_6.5",
  ]
  $network_tools = [
    "traceroute",
    "telnet",
    "bind",
    "bind-libs",
    "bind-utils",
  ]
  $system_tools = [
    "tree",
    "screen",
    "vim-common",
    "vim-enhanced",
    "at",
    "lrzsz",
    "mlocate",
    "unrar",
  ]
  $performance_tools = [
    "innotop",
    "iftop",
    "iotop",
    "lsof",
    "vnstat",
    "sysstat",
    "dstat",
  ]
  $remove_package = [
    "Python-2.7.3-1.x86_64",
  ]
  package { $remove_package:
    ensure => absent,
    before => Package['python-2.7.9-1.el6.x86_64'],
    allow_virtual  => false,
  }
  package {'python-2.7.9-1.el6.x86_64':
    provider       => rpm,
    ensure         => installed,
    allow_virtual  => false,
    source         => "puppet:///modules/centos_env/python-2.7.9-1.el6.x86_64.rpm",
  }
  package { $common_package:
    ensure         => installed,
    require        => Yumrepo["mcyw"],
    allow_virtual  => false,
  }
  package { $network_tools:
    ensure         => installed,
    require        => Yumrepo["mcyw"],
    allow_virtual  => false,
  }
  package { $system_tools:
    ensure         => installed,
    require        => Yumrepo["mcyw"],
    allow_virtual  => false,
  }
  package { $performance_tools:
    ensure         => installed,
    require        => Yumrepo["mcyw"],
    allow_virtual  => false,
  }
}