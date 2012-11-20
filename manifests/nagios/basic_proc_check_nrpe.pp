define admin::nagios::basic_proc_check_nrpe (
  $contact_groups,
  $location
) {
  @@nagios_service { "check_${name}_${fqdn}":
    notification_period => '24x7',
    use                 => 'generic-service',
    host_name           => $::fqdn,
    notify              => Service['nagios3'],
    service_description => $name,
    check_command       => "check_nrpe_1arg!check_${name}",
    contact_groups      => $contact_groups,
    tag                 => $location,
  }

  concat::fragment { "check_${name}":
    target  => '/etc/nagios/nrpe.cfg',
    content => template('admin/nagios/nrpe/check_proc_nrpe.erb'),
    order   => 03,
  }
}
