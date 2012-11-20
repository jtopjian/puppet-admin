#
class admin::data::common {

  # Puppet
  $puppet_server = 'puppet.private.example.com'

  # IPs
  $public_ip  = $::ipaddress_eth1
  $private_ip = $::ipaddress_eth0

  # Trusted networks
  $trusted_networks = ['127.0.0.0/8']

  # Mail aliases
  $root_alias = 'sysadmin@localhost'

}
