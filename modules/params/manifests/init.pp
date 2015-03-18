class params {
  $ssh_port = 61618
  $bashrc_ps1 = get_ps1( "${::hostname}","${::ipaddress}","61618")
  $project_name1 = inline_template("<%= bashrc_ps1.split('_')[0] %>")
  notify {"$project_name1":}
}