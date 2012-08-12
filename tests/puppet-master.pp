class { 'puppet-master': 
  puppet_dashboard_user        => 'puppet-dashboard',
  puppet_dashboard_password    => 'password',
  puppet_dashboard_site        => $::fqdn,
  puppet_storeconfigs_password => 'password',
}
