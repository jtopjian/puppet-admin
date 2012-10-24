#
class admin::data::dc2 {

  # Subnets
  $public_network        = '10.2.0.0/24'
  $private_network       = '192.168.2.0/24'
  $public_network_mysql  = '10.2.0.%'
  $private_network_mysql = '192.168.2.%'
  $pxe_network           = '192.168.254.0/24'

  # Utility Server
  $util_public_hostname  = 'util.dc2.example.com'
  $util_private_hostname = 'util.dc2.private.example.com'
  $util_pxe_hostname     = 'util.dc2.pxe.example.com'
  $util_public_ip        = '192.168.0.2'
  $util_private_ip       = '192.168.2.1'   
  $util_pxe_ip           = '192.168.254.1' 

  # Postfix
  $postfix_relay_host = $util_private_hostname
  $postfix_my_networks = ['127.0.0.0/8', '[::ffff:127.0.0.0]/104', '[::1]/128', $private_network, $pxe_network]

  # rsyslog
  $rsyslog_server = '192.168.2.1'

  # fail2ban
  $fail2ban_ignore_networks = "${private_network}, 127.0.0.1"

  # SSH
  $ssh_util_admin_key  = ''
  $ssh_cloud_admin_key = ''

  # Cloud Stuff

  # Cloud Controller
  $cloud_mysql_host       = $::admin::data::dc1::cloud_private_hostname
  $cloud_public_hostname  = 'cloud.dc2.example.com'
  $cloud_private_hostname = 'cloud.dc2.private.example.com'
  $cloud_public_ip        = '0.0.0.0'
  $cloud_private_ip       = '192.168.2.2'
  $region                 = 'dc2'

  # Nagios
  $nrpe_allowed_hosts = [$cloud_public_ip, $cloud_private_ip, '127.0.0.1']
  
  # Rabbit
  $rabbit_password          = 'password'

  # Nova
  $nova_keystone_password   = 'nova'
  $nova_mysql_user          = 'nova'
  $nova_mysql_dbname        = 'nova'
  $nova_mysql_password      = 'nova'
  $nova_admin_password      = 'nova'
  $libvirt_type             = 'qemu'
  $private_interface        = 'eth0'
  $public_interface         = 'eth1'
  $nova_db = "mysql://${nova_mysql_user}:${nova_mysql_password}@${cloud_mysql_host}/${nova_mysql_dbname}"

  # Cinder
  $cinder_keystone_password = 'password'
  $cinder_mysql_password    = 'password'
  $cinder_mysql_dbname      = 'cinder'
  $cinder_mysql_user        = 'cinder'
  $cinder_db = "mysql://{$cinder_mysql_user}:${cinder_mysql_password}@${cloud_mysql_host}/${cinder_mysql_dbname}"

  # Glance
  $glance_api_servers = "${::admin::data::dc1::cloud_private_hostname}:9292"

}
