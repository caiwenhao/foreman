class centos_env::repo(){
  yumrepo { 'mcyw':
    baseurl        => "http://192.168.137.2:8080/centos/6.2/x86_64",
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
  ]
  package { $common_package:
    ensure         => installed,
    require        => Yumrepo["mcyw"],
    allow_virtual  => false,
  }

}