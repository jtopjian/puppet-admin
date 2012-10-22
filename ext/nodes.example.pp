# Config that gets applied to all servers
node base {

  class { 'ntp': }
  class { 'stdlib': }
  class { 'admin::ssh::hostkeys': }
  class { 'admin::mail::aliases': }
  class { 'admin::security-updates': }
  class { 'admin::fail2ban':                     ignore_networks => hiera('fail2ban_ignore_networks') }
  class { 'admin::nagios::nrpe':                 allowed_hosts   => hiera('nrpe_allowed_hosts') }
  class { 'admin::nagios::basic_host_checks':    contact_groups  => 'oncall' }
  class { 'admin::nagios::basic_service_checks': contact_groups  => 'sysadmins' }

  admin::functions::enable_ssh_key { 'util': 
    user => 'root', 
    key  => hiera('ssh_util_admin_key'),
  }

  admin::functions::enable_ssh_key { 'cloud': 
    user => 'root', 
    key  => hiera('ssh_cloud_admin_key'),
  }

  Host<<| tag == 'all' |>>
}

# Config for a "basic" server - basically any server that doesn't require
# a very specific configuration
node basic_server inherits base {
  class { 'admin::basepackages': }
  class { 'puppet':                       puppet_server  => hiera('puppet_server') }
  class { 'admin::apt-cacher-ng::client': server         => hiera('puppet_server') }
  class { 'admin::mail::postfix':         relayhost      => hiera('postfix_relay_host') }
  class { 'admin::rsyslog::client':       rsyslog_server => hiera('rsyslog_server') }
}

node dc1 inherits basic_server {
  admin::functions::add_host { $::fqdn:
    ip       => hiera('private_ip'),
    location => 'dc1',
  }

  Host <<| tag == 'dc1' |>>
}

node dc2 inherits basic_server {
  admin::functions::add_host { $::fqdn:
    ip       => hiera('private_ip'),
    location => 'dc2',
  }

  Host <<| tag == 'dc2' |>>
}

# Utility Server
node 'util.dc1.example.com' inherits base {
  class { 'admin::basepackages': }
  class { 'admin::backups::mysql': }
  class { 'admin::util-server':
    util_public_hostname         => hiera('util_public_hostname'),
    mysql_root_password          => hiera('mysql_root_password'),
    puppet_dashboard_user        => hiera('puppet_dashboard_user'),
    puppet_dashboard_password    => hiera('puppet_dashboard_password'),
    puppet_dashboard_site        => hiera('util_public_hostname'),
    cobbler_dhcp_start_range     => hiera('cobbler_dhcp_start_range'),
    cobbler_dhcp_stop_range      => hiera('cobbler_dhcp_stop_range'),
    cobbler_next_server          => hiera('cobbler_next_server'),
    cobbler_server               => hiera('cobbler_server'),
    cobbler_password             => hiera('cobbler_password'),
    postfix_my_networks          => hiera('postfix_my_networks'),
  }
  class { 'admin::nagios::server':           admin_password => hiera('nagios_admin_password') }
  class { 'admin::rsyslog::server':          interface      => hiera('private_ip') }
  class { 'admin::nagios::check_mysql_nrpe': contact_groups => 'sysadmins' }

  $public_hostname  = hiera('util_public_hostname')
  $private_hostname = hiera('util_private_hostname')
  admin::functions::add_host { $public_hostname:
    ip       => hiera('util_public_ip'),
    aliases  => [$::hostname],
    location => 'all'
  }

  admin::functions::add_host { $private_hostname:
    ip       => hiera('util_private_ip'),
    location => 'dc1'
  }

  Host<<| tag == 'dc1' |>>

}

# Cloud Controller
node 'cloud.dc1.example.com' inherits basic_server {
  class { 'admin::backups::mysql': }
  class { 'admin::cloud::controller': }

  $public_hostname = hiera('cloud_public_hostname')
  admin::functions::add_host { $public_hostname:
    ip       => hiera('cloud_public_ip'),
    aliases  => [$::hostname],
    location => 'all',
  }

  $private_hostname = hiera('cloud_private_hostname')
  admin::functions::add_host { $private_hostname:
    ip       => hiera('cloud_private_ip'),
    location => 'dc1',
  }

  Host <<| tag == 'dc1' |>>

}

# Compute Nodes
node 'c01.dc1.example.com',
     'c02.dc1.example.com'  inherits basic_server {
  class { 'admin::cloud::compute': }
}
