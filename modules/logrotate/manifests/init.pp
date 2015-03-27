class logrotate(){
  logrotate::rule { 'syslog':
    path          => ['/var/log/messages','/var/log/cron','/var/log/maillog','/var/log/secure','/var/log/spooler'],
    rotate        => 5,
    rotate_every  => 'week',
    postrotate    => '/bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true',
    sharedscripts => true,
  }
  logrotate::rule { 'dracut':
    path         => "/var/log/dracut.log",
    rotate       => 5,
    missingok    => true,
    ifempty      => false,
    rotate_every => 'week',
    create_owner => 'root',
    create_group => 'root',
    create_mode  => '0660',
    create       => true,
    size         => "30k"
  }
  logrotate::rule { 'named':
    rotate       => 5,
    path         => "/var/named/data/named.run",
    missingok    => true,
    create_owner => 'named',
    create_group => 'named',
    create_mode  => '0644',
    create       => true,
    rotate_every  => 'week',
    postrotate   => "/sbin/service named reload  2> /dev/null > /dev/null || true",
  }
  logrotate::rule { 'yum':
    rotate       => 5,
    path         => "/var/log/yum.log",
    missingok    => true,
    ifempty      => false,
    create_owner => 'root',
    create_group => 'root',
    create_mode  => '0600',
    size         => "30k",
    create       => true,
    rotate_every => 'week',
  }
}