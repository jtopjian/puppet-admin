#
class admin::data::dc2 {

  include admin::data::common

  # Subnets
  $public_network        = '10.2.0.0/24'
  $private_network       = '192.168.2.0/24'
  $public_network_mysql  = '10.2.0.%'
  $private_network_mysql = '192.168.2.%'
  $pxe_network           = '192.168.254.0/24'
  $pxe_network_mysql     = '192.168.254.%'

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
  $tnetworks = join($::admin::data::common::trusted_networks, ' ') 
  $fail2ban_ignore_networks = "${private_network} 127.0.0.1 ${tnetworks} ${public_network}"

  # SSH
  $ssh_util_admin_key  = ''
  $ssh_cloud_admin_key = ''

  # Mail aliases
  $mail_root_alias = ['root@localhost']

  # Cloud Stuff

  # Cloud Controller
  $cloud_public_hostname     = 'cloud.dc2.example.com'
  $cloud_private_hostname    = 'cloud.dc2.private.example.com'
  $cloud_public_ip           = '0.0.0.0'
  $cloud_private_ip          = '192.168.2.2'
  $keystone_public_hostname  = 'keystone.dc2.example.com'
  $keystone_private_hostname = 'keystone.dc2.private.example.com'
  $keystone_public_ip        = '0.0.0.0'
  $keystone_private_ip       = '192.168.2.2'
  $cloud_mysql_host          = $cloud_private_hostname
  $region                    = 'dc2'

  # Nagios
  $nrpe_allowed_hosts = [$cloud_public_ip, $cloud_private_ip, '127.0.0.1']

  # Rabbit
  $rabbit_user              = 'nova'
  $rabbit_host              = $cloud_public_ip
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
  $internal_interface       = 'vlan11'
  $nova_db = "mysql://${nova_mysql_user}:${nova_mysql_password}@${cloud_mysql_host}/${nova_mysql_dbname}"

  # Cinder
  $cinder_keystone_password = 'password'
  $cinder_mysql_password    = 'password'
  $cinder_mysql_dbname      = 'cinder'
  $cinder_mysql_user        = 'cinder'
  $cinder_db = "mysql://${cinder_mysql_user}:${cinder_mysql_password}@${cloud_mysql_host}/${cinder_mysql_dbname}"

  # Glance
  $glance_api_servers = "${cloud_private_hostname}:9292"
  $glance_host        = $cloud_public-ip

  # Swift
  $swift_hash_suffix       = 'shared_secret'
  $swift_keystone_password = 'password'
  $swift_public_ip         = '1.1.1.1'

  # mcollective
  $mcollective_server   = $cloud_public_ip
  $mcollective_password = 'password'
  $mcollective_psk      = 'password'

}
