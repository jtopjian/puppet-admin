class admin::data::dc1 {

  # Subnets
  $private_network = '192.168.1.0/24'
  $pxe_network     = '192.168.255.0/24'

  # Utility Server
  $util_public_hostname  = 'util.dc1.example.com'
  $util_private_hostname = 'util.dc1.private.example.com'
  $util_pxe_hostname     = 'util.dc1.pxe.example.com'

  # Postfix
  $postfix_relay_host = $util_private_hostname
  $postfix_my_networks = ['127.0.0.0/8', '[::ffff:127.0.0.0]/104', '[::1]/128', $private_network, $pxe_network]

  # Nagios
  $nrpe_allowed_hosts = [$private_network, $pxe_network, '127.0.0.1']
  
  # rsyslog
  $rsyslog_server = '192.168.1.1'

  # fail2ban
  $fail2ban_ignore_networks = "${private_network}, 127.0.0.1"

  # Cloud Stuff

  # Cloud Controller
  $cloud_public_hostname  = 'cloud.dc1.example.com'
  $cloud_private_hostname = 'cloud.dc1.private.example.com'
  $cloud_public_ip        = '0.0.0.0'
  $cloud_private_ip       = '192.168.1.2'

  # Nova
  $nova_mysql_user          = 'nova'
  $nova_mysql_dbname        = 'nova'
  $nova_mysql_password      = 'nova'
  $libvirt_type             = 'kvm'
  $private_interface        = 'eth0'
  $public_interface         = 'eth1'
  $nova_db = "mysql://${nova_mysql_user}:${nova_mysql_password}@${mysql_host}/${nova_mysql_dbname}"

}
