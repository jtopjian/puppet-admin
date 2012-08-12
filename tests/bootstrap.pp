include admin::params
include admin::params::cloud

class { 'admin::basepackages': }
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
