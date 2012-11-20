class admin::nagios::check_kvm-pegged_nrpe ( 
  $contact_groups,
  $location
) inherits admin::nagios::global_nrpe {
  @@nagios_service { "check_kvm-pegged_${fqdn}":
    service_description => 'KVM Pegged',
    check_command       => 'check_nrpe_1arg!check_kvm_peg!',
    contact_groups      => $contact_groups,
    tag                 => $location,
  }

  concat::fragment { 'check_kvm-pegged':
    target  => '/etc/nagios/nrpe.cfg',
    content => template('admin/nagios/nrpe/check_kvm-pegged_nrpe.erb'),
    order   => 03,
  }

}
