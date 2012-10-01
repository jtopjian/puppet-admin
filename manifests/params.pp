class admin::params {

  # Server
  $util_public_hostname  = 'util.sandbox.example.com'
  $util_private_hostname = 'util.private.sandbox.example.com'

  # Nagios
  $nrpe_allowed_hosts    = ['192.168.6.1', '127.0.0.1']
  $nagios_admin_password = 'insert encrypted pw here'
 
  # Postfix
  $postfix_relay_host  = 'util.private.sandbox.example.com'
  $postfix_my_networks = ['127.0.0.0/8', '[::ffff:127.0.0.0]/104', '[::1]/128', '192.168.6.0/24']

  # MySQL
  $mysql_root_password = 'password'

  # Puppet
  $puppet_server                = 'util.private.sandbox.example.com'
  $puppet_storeconfigs_password = 'password'
  $puppet_dashboard_user        = 'puppet-dashboard'
  $puppet_dashboard_password    = 'password'
 
  # Cobbler
  $cobbler_dhcp_start_range = '192.168.6.200'
  $cobbler_dhcp_stop_range  = '192.168.6.250'
  $cobbler_next_server      = $::ipaddress_eth0
  $cobbler_server           = $::ipaddress_eth0

  # SSH
  $ssh_util_admin_key = ''
  $ssh_cloud_admin_key = ''

  # IPs
  $public_ip  = $::ipaddress_eth1
  $private_ip = $::ipaddress_eth0

  # rsyslog
  $rsyslog_server = '192.168.1.1'

  # fail2ban
  $fail2ban_ignore_networks = '127.0.0.1 192.168.1.0/24'

}

class admin::params::cloud inherits params {
  # MySQL
  $mysql_root_password      = 'password'
  $mysql_bind_address       = '0.0.0.0'
  $mysql_allowed_hosts      = ['192.168.6.%', '127.0.0.%']
  $mysql_host               = 'cloud.private.sandbox.example.com'

  # Keystone
  $keystone_admin_token     = '12345'
  $keystone_admin_email     = 'root@localhost'
  $keystone_admin_password  = 'password'
  $keystone_admin_tenant    = 'admin'
  $keystone_mysql_dbname    = 'keystone'
  $keystone_mysql_user      = 'keystone_admin'
  $keystone_mysql_password  = 'password'
  $keystone_host            = 'cloud.private.sandbox.example.com'

  # Glance
  $glance_keystone_password = 'password'
  $glance_mysql_dbname      = 'glance'
  $glance_mysql_user        = 'glance'
  $glance_mysql_password    = 'password'
  $glance_host              = 'cloud.private.sandbox.example.com'

  # Horizon
  $horizon_secret_key       = 'dummy_secret_key'
  $horizon_app_links        = "[['Nagios','http://${::admin::params::util_public_hostname}/nagios3'],]"

  # RabbitMQ
  $rabbit_password          = 'password'
  $rabbit_user              = 'nova'
  $rabbit_host              = 'cloud.private.sandbox.example.com'

  # Nova
  $nova_mysql_user          = 'nova'
  $nova_mysql_dbname        = 'nova'
  $nova_mysql_password      = 'nova'
  $nova_admin_password      = 'nova'
  $libvirt_type             = 'kvm'
  $private_interface        = 'eth0'
  $public_interface         = 'eth1'
  $vlan_start               = '100'
  $fixed_range              = '10.0.0.0/8'
  $num_networks             = '255'
  $floating_range           = '192.168.1.0/24'

  $controller_public_hostname  = 'cloud.sandbox.example.com'
  $controller_private_hostname = 'cloud.private.sandbox.example.com'
  $controller_public_ip        = '0.0.0.0'
  $controller_private_ip       = '192.168.6.2'


  # More MySQL
  $glance_db = "mysql://${glance_mysql_user}:${glance_mysql_password}@${mysql_host}/${glance_mysql_dbname}"
  $nova_db = "mysql://${nova_mysql_user}:${nova_mysql_password}@${mysql_host}/${nova_mysql_dbname}"
}
