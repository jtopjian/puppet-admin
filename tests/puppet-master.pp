class { 'mysql': }
class { 'mysql::server':
  config_hash => {
    'root_password' => 'password',
    'bind_address' => '0.0.0.0',
  }
}
class { 'mysql::server::account_security': }
  
class { 'admin::puppet::master': 
  puppet_dashboard_user        => 'puppet-dashboard',
  puppet_dashboard_password    => 'password',
  puppet_dashboard_site        => $::fqdn,
  puppet_storeconfigs_password => 'password',
}
