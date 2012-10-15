import 'passwords.pp'

class { 'mysql': }
class { 'mysql::server':
  config_hash => {
    'root_password' => $mysql_password,
    'bind_address' => '0.0.0.0',
  }
}
class { 'mysql::server::account_security': }

Class['mysql::server'] -> Class['admin::puppet::master']
  
class { 'admin::puppet::master': 
  puppet_dashboard_user        => 'puppet-dashboard',
  puppet_dashboard_password    => $puppet_dashboard_password,
  puppet_dashboard_site        => $::fqdn,
}
