class centos_env::sysctl(
  $shmmax = inline_template("<%= @memorysize_mb.to_i*1024*1024 %>"),
  $shmall = inline_template("<%= @memorysize_mb.to_i*1024/4 %>")
){
  exec {"sysctl -p":
    alias       => "sysctl",
    refreshonly => true,
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }
  augeas {"sysctl":
    context => "/files/etc/sysctl.conf",
    changes =>[
      "rm net.bridge.bridge-nf-call-ip6tables",
      "rm net.bridge.bridge-nf-call-iptables",
      "rm net.bridge.bridge-nf-call-arptables",
      "set net.ipv4.ip_forward 0",
      "set net.ipv4.conf.default.rp_filter 1",
      "set net.ipv4.conf.default.accept_source_route 0",
      "set kernel.sysrq 0",
      "set kernel.core_uses_pid 1",
      "set net.ipv4.tcp_syncookies 1",
      "set kernel.msgmnb 0",
      "set kernel.msgmax 65536",
      "set kernel.shmmax ${shmmax}",
      "set kernel.shmall ${shmall}",
      "set kernel.shmmni 4096",
      "set net.nf_conntrack_max 655360",
      "set net.netfilter.nf_conntrack_max 655360",
      "set net.netfilter.nf_conntrack_tcp_timeout_established 1200",
      "set net.ipv4.tcp_window_scaling 1",
      "set net.ipv4.tcp_sack 1",
      "set net.ipv4.tcp_timestamps 0",
      "set net.ipv4.tcp_synack_retries 2",
      "set net.ipv4.tcp_syn_retries 2",
      "set net.ipv4.tcp_tw_reuse 1",
      "set net.ipv4.tcp_tw_recycle 1",
      "set net.ipv4.ip_local_port_range '1024 65000'",
      "set net.ipv4.tcp_max_syn_backlog 8192",
      "set net.ipv4.ip_local_reserved_ports '3306,4369,8000-8300,9000-9300,20000-30000,61618'",
      "set net.ipv4.tcp_fin_timeout 30",
      "set net.ipv4.tcp_retries2 5",
      "set net.ipv4.tcp_max_tw_buckets 180000",
      "set net.core.somaxconn 1024",
      "set kernel.core_pattern /data/tmp/core",
    ],
    notify  => Exec['sysctl'],
  }

}