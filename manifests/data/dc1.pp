#
class admin::data::dc1 {

  # Subnets
  $public_network        = '10.1.0.0/24'
  $private_network       = '10.0.0.0/24'
  $public_network_mysql  = '10.1.0.%'
  $private_network_mysql = '10.0.0.%'
  $pxe_network           = '192.168.255.0/24'
  $pxe_network_mysql     = '192.168.255.%'

  # Utility Server
  $util_public_hostname  = 'p2.dc1.example.com'
  $util_private_hostname = 'p2.dc1.private.example.com'
  $util_pxe_hostname     = 'p2.dc1.pxe.example.com'
  $util_public_ip        = '10.1.0.28'
  $util_private_ip       = '10.0.0.68'   
  $util_pxe_ip           = '192.168.255.1' 

  # Postfix
  $postfix_relay_host = $util_private_hostname
  $postfix_my_networks = ['127.0.0.0/8', '[::ffff:127.0.0.0]/104', '[::1]/128', $private_network, $pxe_network]

  # rsyslog
  $rsyslog_server = '10.1.0.28'

  # fail2ban
  $fail2ban_ignore_networks = "${private_network}, 127.0.0.1"

  # SSH
  $ssh_util_admin_key  = ''
  $ssh_cloud_admin_key = ''

  # Cloud Stuff

  # Cloud Controller
  $cloud_public_hostname     = 'cloud.dc1.example.com'
  $cloud_private_hostname    = 'cloud.dc1.private.example.com'
  $cloud_public_ip           = '10.1.0.32'
  $cloud_private_ip          = '10.0.0.66'
  $keystone_public_hostname  = 'keystone.dc1.example.com'
  $keystone_private_hostname = 'keystone.dc1.private.example.com'
  $keystone_public_ip        = '10.1.0.32'
  $keystone_private_ip       = '10.0.0.66'
  $cloud_mysql_host          = $cloud_public_hostname
  $region                    = 'dc1'

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
  $private_interface        = 'eth1'
  $public_interface         = 'eth0'
  $nova_db = "mysql://${nova_mysql_user}:${nova_mysql_password}@${cloud_mysql_host}/${nova_mysql_dbname}"

  # Cinder
  $cinder_keystone_password = 'password'
  $cinder_mysql_password    = 'password'
  $cinder_mysql_dbname      = 'cinder'
  $cinder_mysql_user        = 'cinder'
  $cinder_db = "mysql://${cinder_mysql_user}:${cinder_mysql_password}@${cloud_mysql_host}/${cinder_mysql_dbname}"

  # Glance
  $glance_api_servers = "${cloud_public_hostname}:9292"

  # Swift
  $swift_hash_suffix       = 'shared_secret'
  $swift_keystone_password = 'password'
  $swift_public_ip         = '1.1.1.1'

}
