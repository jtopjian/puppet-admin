class admin::data::common {

  # Puppet
  $puppet_server = 'puppet.private.example.com'
 
  # SSH
  $ssh_keys = []

  # IPs
  $public_ip  = $::ipaddress_eth1
  $private_ip = $::ipaddress_eth0

  # Mail aliases
  $root_alias = 'sysadmin@localhost'

}
