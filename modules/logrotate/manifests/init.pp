class logrotate(){
  logrotate::rule { 'messages':
    path         => '/var/log/messages',
    rotate       => 5,
    rotate_every => 'week',
    postrotate   => '/usr/bin/killall -HUP syslogd',
  }
}