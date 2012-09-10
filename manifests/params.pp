class admin::params {

  # Server
  $util_public_hostname  = 'puppet.example.com'
  $util_private_hostname = 'puppet.private.example.com'

  # Nagios
  $nrpe_allowed_hosts    = ['10.0.0.23', '127.0.0.1', '10.0.2.2']
  $nagios_admin_password = 'password'
 
  # Postfix
  $postfix_relay_host  = 'puppet.example.com'
  $postfix_my_networks = ['127.0.0.0/8', '[::ffff:127.0.0.0]/104', '[::1]/128', '10.0.0.0/24', '10.0.2.0/24']

  # MySQL
  $mysql_root_password = 'password'

  # Puppet
  $puppet_server                = 'puppet.example.com'
  $puppet_storeconfigs_password = 'password'
  $puppet_dashboard_user        = 'puppet-dashboard'
  $puppet_dashboard_password    = 'password'
 
  # Cobbler
  $cobbler_dhcp_start_range = '192.168.6.200'
  $cobbler_dhcp_stop_range  = '192.168.6.250'
  $cobbler_next_server      = $::ipaddress_eth0
  $cobbler_server           = $::ipaddress_eth0

  # SSH
  $ssh_util_admin_key = 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC+SThJVqauVAe6MHyrDYHLOfbAKumxAhIr1IBEWBenq+bmBBWnm83pBmdV8BKpZWnvfZ5+mJXu1zbYsR4g+AHTfoyJO7W3oiJxkLP94OCTPDXR1VePzHL1XKKOQq0yGsjQPAAbOR8ONnGRyoB/ZDk25J7PqnjeR86UEPH3Vao0xY2YZkJwBzrMJEUoCkkkL0dKJclIoL89PR3o0nvitcExEoPRERfE6su3DimTiBi1yO86ewDM+qwHfPDC2txRDUrxcoCS6Lma/Sp+hG8n5hAXkZRCjOKNDCBSKqfayWbtNK+7Cg3uLnmZZ3/I9GNzDBR/WLIGol9g2/BxFPKBhzQP'
  $ssh_cloud_admin_key = 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDOT/G9oCshcibDhpdcN4B5DIaKx57Zx3iExpMDkzf5B1dBsZqDAX+ZD5UWqvVZJ+bVbC4E3qxnOxUZokBK7r2exw8PkqkE/tEQ8RmAiFQpYbfq+s663F7exXsvo18014QtKNEPROaiiu7GO5kJYIR3D1AmyahQc6FvzHf/W/4bBniuuhDfgJw6bmFfoEhBgx+tHaatllZPrf0ZzgQZwawFGTSYMioSK1mIbHnkLKXCy1n6XstLa2di4nDQeOyyNkVOHFQURk+aeluEwm9+Mag5/mCZ4eXvaGEm1eA7UlP9pcR4mu6tr1CIifm/Br8nvjvKKqZCCRRobF6GG7fAeUR3'

  # IPs
  $public_ip  = $::ipaddress_eth1
  $private_ip = $::ipaddress_eth0

  # rsyslog
  $rsyslog_server = '10.0.0.23'

  # fail2ban
  $fail2ban_ignore_networks = '127.0.0.1 10.0.0.0/24 10.0.2.0/24'

}

class admin::params::cloud inherits params {
  # MySQL
  $mysql_root_password      = 'password'
  $mysql_bind_address       = '0.0.0.0'
  $mysql_allowed_hosts      = ['10.0.0.%', '10.0.2.%', '127.0.0.%']
  $mysql_host               = 'cloud.example.com'

  # Keystone
  $keystone_admin_token     = '12345'
  $keystone_admin_email     = 'root@localhost'
  $keystone_admin_password  = 'password'
  $keystone_admin_tenant    = 'admin'
  $keystone_mysql_dbname    = 'keystone'
  $keystone_mysql_user      = 'keystone_admin'
  $keystone_mysql_password  = 'password'
  $keystone_host            = 'cloud.example.com'
  $keystone_db = "mysql://${keystone_mysql_user}:${keystone_mysql_password}@${mysql_host}/${keystone_mysql_dbname}"

  # Glance
  $glance_keystone_password = 'password'
  $glance_mysql_dbname      = 'glance'
  $glance_mysql_user        = 'glance'
  $glance_mysql_password    = 'password'
  $glance_host              = 'cloud.example.com'
  $glance_db = "mysql://${glance_mysql_user}:${glance_mysql_password}@${mysql_host}/${glance_mysql_dbname}"

  # Quantum
  $quantum_keystone_password = 'password'
  $quantum_mysql_user        = 'quantum'
  $quantum_mysql_dbname      = 'quantum'
  $quantum_mysql_password    = 'password'
  $quantum_db = "mysql://${quantum_mysql_user}:${quantum_mysql_password}@${mysql_host}/${quantum_mysql_dbname}"
  
  # Cinder
  $cinder_keystone_password  = 'password'
  $cinder_mysql_user         = 'cinder'
  $cinder_mysql_dbname       = 'cinder'
  $cinder_mysql_password     = 'password'
  $cinder_db = "mysql://${cinder_mysql_user}:${cinder_mysql_password}@${mysql_host}/${cinder_mysql_dbname}"

  # Horizon
  $horizon_secret_key       = 'dummy_secret_key'
  $horizon_app_links        = "[['Nagios','http://${::admin::params::util_public_hostname}/nagios3'],]"

  # RabbitMQ
  $rabbit_password          = 'password'
  $rabbit_user              = 'nova'
  $rabbit_host              = 'cloud.example.com'

  # Nova
  $nova_keystone_password   = 'nova'
  $nova_mysql_user          = 'nova'
  $nova_mysql_dbname        = 'nova'
  $nova_mysql_password      = 'nova'
  $nova_admin_password      = 'nova'
  $nova_db = "mysql://${nova_mysql_user}:${nova_mysql_password}@${mysql_host}/${nova_mysql_dbname}"
  $libvirt_type             = 'kvm'
  $private_interface        = 'eth0'
  $public_interface         = 'eth1'
  $vlan_start               = '100'
  $fixed_range              = '10.1.0.0/8'
  $num_networks             = '255'
  $floating_range           = '192.168.33.0/24'

  $controller_public_hostname  = 'cloud.example.com'
  $controller_private_hostname = 'cloud.example.com'
  $controller_public_ip        = '10.0.0.32'
  $controller_private_ip       = '10.0.2.7'


  # More MySQL
}
