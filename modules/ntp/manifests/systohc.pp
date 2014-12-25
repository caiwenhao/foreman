class ntp::systohc inherits ntp {
  exec {'hwclock systohc':
    command => "/usr/bin/pkill ntpd && /usr/sbin/ntpdate $first_servers && /sbin/hwclock --systohc",
    creates => '/var/tmp/ntp'
  }
}
