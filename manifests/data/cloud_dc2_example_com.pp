#
class admin::data::cloud_dc2_example_com {

  include admin::data::dc2

  # Nagios
  $nagios_admin_password = 'password'

  # MySQL
  $mysql_root_password      = 'password'
  $mysql_bind_address       = '0.0.0.0'
  $mysql_allowed_hosts      = [$::admin::data::dc2::private_network_mysql, $::admin::data::dc2::public_network_mysql, $::admin::data::dc2::pxe_network_mysql, '127.0.0.%']

  # Keystone
  $keystone_admin_token     = '12345'
  $keystone_admin_email     = 'root@localhost'
  $keystone_admin_password  = 'password'
  $keystone_admin_tenant    = 'admin'
  $keystone_mysql_dbname    = 'keystone'
  $keystone_mysql_user      = 'keystone_admin'
  $keystone_mysql_password  = 'password'
  $keystone_host            = $::admin::data::dc2::cloud_private_hostname

  # Glance
  $glance_keystone_password = 'password'
  $glance_mysql_dbname      = 'glance'
  $glance_mysql_user        = 'glance'
  $glance_mysql_password    = 'password'
  $glance_host              = $::admin::data::dc2::cloud_private_hostname
  $glance_db = "mysql://${glance_mysql_user}:${glance_mysql_password}@${mysql_host}/${glance_mysql_dbname}"

  # Horizon
  $horizon_secret_key       = 'dummy_secret_key'
  $horizon_app_links        = "[['Nagios','http://${::admin::params::data::util_public_hostname}/nagios3'],]"

  # RabbitMQ
  $rabbit_user              = 'nova'
  $rabbit_host              = $::admin::data::dc2::cloud_private_hostname

  # Nova
  $vlan_start               = '100'
  $fixed_range              = '10.0.0.0/8'
  $num_networks             = '255'
  $floating_range           = '192.168.12.0/24'

}
