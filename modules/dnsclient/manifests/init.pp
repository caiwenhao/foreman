# ## Class: dnsclient ##
#
# This module manages /etc/resolv.conf and is meant to be included in the
# common class that applies to all systems.
#
class dnsclient                 (
  $nameservers                 = ['121.10.118.123','114.114.114.114','223.5.5.5','223.6.6.6','112.124.47.27','202.96.128.143','202.96.128.166','202.96.128.86'],
  $options                     = [ 'rotate',
                                  'timeout:1'],
  $search                      = ['UNSET'],
  $domain                      = 'UNSET',
  $sortlist                    = ['UNSET'],
  $resolver_config_file        = '/etc/resolv.conf',
  $resolver_config_file_ensure = 'file',
  $resolver_config_file_owner  = 'root',
  $resolver_config_file_group  = 'root',
  $resolver_config_file_mode   = '0644',
) {

  # Validates domain
  if is_domain_name($domain) != true {
    fail("Domain name, ${domain}, is invalid.")
  }

  # Validates $resolver_config_file_ensure
  case $resolver_config_file_ensure {
    'file', 'present', 'absent': {
      # noop, these values are valid
    }
    default: {
      fail("Valid values for \$resolver_config_file_ensure are \'absent\', \'file\', or \'present\'. Specified value is ${resolver_config_file_ensure}")
    }
  }

  file { 'dnsclient_resolver_config_file':
    ensure  => $resolver_config_file_ensure,
    content => template('dnsclient/resolv.conf.erb'),
    path    => $resolver_config_file,
    owner   => $resolver_config_file_owner,
    group   => $resolver_config_file_group,
    mode    => $resolver_config_file_mode,
  }
}
