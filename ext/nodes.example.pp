# Basic server attributes
node base_server {
  class { 'ntp': }
  class { 'admin::ssh::hostkeys': }
  class { 'admin::mail::aliases': }
  class { 'admin::security-updates': }
  class { 'admin::hosts': ip_address => $::admin::params:_ip }
  class { 'admin::fail2ban': ignore_networks => $::admin::params::fail2ban_ignore_networks }
  class { 'admin::nagios::nrpe': allowed_hosts => $::admin::params::nrpe_allowed_hosts }
  class { 'admin::nagios::basic_host_checks': contact_groups => 'oncall' }
  class { 'admin::nagios::basic_service_checks': contact_groups => 'sysadmins' }

  admin::functions::enable_ssh_key { 'util': 
    user => 'root', 
    key  => $::admin::params::ssh_util_admin_key,
  }

  admin::functions::enable_ssh_key { 'cloud': 
    user => 'root', 
    key  => $::admin::params::ssh_cloud_admin_key,
  }
}

node basic_server inherits base_server {
  class { 'admin::basepackages': }
  class { 'puppet': puppet_server => $::admin::params::puppet_server }
  class { 'admin::apt-cacher-ng::client': server => $::admin::params::puppet_server }
  class { 'admin::mail::postfix': relayhost => $::admin::params::postfix_relay_host }
  class { 'admin::rsyslog::client': rsyslog_server => $::admin::params::rsyslog_server }
}

# Utility Server
node 'util.example.com' inherits base_server {
  class { 'admin::basepackages': }
  class { 'admin::backups::mysql': }
  class { 'admin::util-server':
    mysql_root_password          => $::admin::params::mysql_root_password,
    puppet_dashboard_user        => $::admin::params::puppet_dashboard_user,
    puppet_dashboard_password    => $::admin::params::puppet_dashboard_password,
    puppet_dashboard_site        => $::admin::params::util_public_hostname,
    puppet_storeconfigs_password => $::admin::params::puppet_storeconfigs_password,
    cobbler_dhcp_start_range     => $::admin::params::cobbler_dhcp_start_range,
    cobbler_dhcp_stop_range      => $::admin::params::cobbler_dhcp_stop_range,
    cobbler_next_server          => $::admin::params::cobbler_next_server,
    cobbler_server               => $::admin::params::cobbler_server,
    postfix_my_networks          => $::admin::params::postfix_my_networks,
  }
  class { 'admin::nagios::server': admin_password => $::admin::params::nagios_admin_password }
  class { 'admin::rsyslog::server': interface => $::admin::params:_ip }
  class { 'admin::nagios::check_mysql_nrpe': contact_groups => 'sysadmins' }
}

# Cloud Controller
node 'cloud.example.com' inherits basic_server {
  class { 'admin::backups::mysql': }
  class { 'admin::cloud::controller': }
}

# Compute Nodes
node 'c01.example.com',
     'c02.example.com'  inherits basic_server {
  class { 'admin::cloud::compute': }
}
