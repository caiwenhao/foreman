class logrotate(){
  logrotate::rule { 'messages':
    path         => '/var/log/messages',
    rotate       => 5,
    rotate_every => 'week',
    postrotate   => '/bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true',
  }
}