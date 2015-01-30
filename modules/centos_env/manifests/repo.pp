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
    "python-2.7.9-1.el6.x86_64",
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