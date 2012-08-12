class admin::nagios::global_nrpe {
  Nagios_host {
    ensure         => present,
    use            => 'generic-host',
    notify         => Service['nagios3'],
    target         => '/etc/nagios3/conf.d/nagios_hosts.cfg',
    require        => File['/etc/nagios3/conf.d/nagios_hosts.cfg'],
  }

  Nagios_service {
    host_name      => $fqdn,
    ensure         => present,
    use            => 'generic-service',
    notify         => Service['nagios3'],
    target         => '/etc/nagios3/conf.d/nagios_services.cfg',
    require        => File['/etc/nagios3/conf.d/nagios_services.cfg'],
  }
}
