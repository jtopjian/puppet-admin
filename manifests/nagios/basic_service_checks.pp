class admin::nagios::basic_service_checks (
  $contact_groups
) inherits admin::nagios::global_nrpe {

  @@nagios_service { "check_ping_${hostname}":
     service_description => 'Ping',
     check_command       => 'check_ping!100.0,20%!500.0,60%',
     contact_groups      => $contact_groups,
  }

  # For NRPE commands - do NOT forget to add it to the nrpe.erb file
  # Too complicated to automate this - for now, anyway.
  @@nagios_service { "check_load_${hostname}":
     service_description => 'Load',
     check_command       => 'check_nrpe!check_load!4.0 4.0 4.0 8.0 6.0 4.0',
     contact_groups      => $contact_groups,
  }

  @@nagios_service { "check_zombie_procs_${hostname}":
     service_description => 'Zombie Procs',
     check_command       => 'check_nrpe!check_zombie_procs!5 10',
     contact_groups      => $contact_groups,
  }

  @@nagios_service { "check_total_procs_${hostname}":
     service_description => 'Total Procs',
     check_command       => 'check_nrpe!check_total_procs!200 300',
     contact_groups      => $contact_groups,
  }

  @@nagios_service { "check_all_disks_${hostname}":
     service_description => 'Disk',
     check_command       => 'check_nrpe!check_all_disks!20% 10%',
     contact_groups      => $contact_groups,
  }

  $nrpe = '/etc/nagios/nrpe.cfg'
  concat::fragment { 'nrpe_basic_checks':
    target  => $nrpe,
    content => template('admin/nagios/nrpe/nrpe_basic_checks.erb'),
    order   => 02,
  }

}
