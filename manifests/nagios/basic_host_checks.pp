class admin::nagios::basic_host_checks ( 
  $contact_groups,
  $location
) inherits admin::nagios::global_nrpe {
  @@nagios_host { $fqdn:
      alias          => $hostname,
      address        => $ipaddress_eth0,
      contact_groups => $contact_groups,
      tag            => $location,
  }
}
