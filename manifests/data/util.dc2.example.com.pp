# util.dc2.example.com
#
# This server acts as the following:
#  - Nagios
#  - Mail relay
#  - rsyslog server
#  - Cobbler
#  - Puppet master, dashboard, puppetdb

class admin::data::util.dc2.example.com {
  # Nagios
  $nagios_admin_password = 'password'

  # MySQL
  $mysql_root_password = 'password'

  # Cobbler
  $cobbler_dhcp_start_range = '192.168.254.200'
  $cobbler_dhcp_stop_range  = '192.168.254.250'
  $cobbler_next_server      = $::ipaddress_eth0
  $cobbler_server           = $::ipaddress_eth0
}
