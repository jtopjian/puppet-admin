# util.dc1.example.com
#
# This server acts as the following:
#  - Nagios
#  - Mail relay
#  - rsyslog server
#  - Cobbler
#  - Puppet master, dashboard, puppetdb

class admin::data::util_dc1_example_com {
  # Nagios
  $nagios_admin_password = 'password'

  # MySQL
  $mysql_root_password = 'password'

  # Puppet
  $puppet_dashboard_user     = 'puppet-dashboard'
  $puppet_dashboard_password = 'password'

  # Cobbler
  $cobbler_dhcp_start_range = '192.168.255.200'
  $cobbler_dhcp_stop_range  = '192.168.255.250'
  $cobbler_next_server      = $::ipaddress_eth0
  $cobbler_server           = $::ipaddress_eth0
}
