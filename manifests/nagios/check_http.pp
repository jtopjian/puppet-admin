class admin::nagios::check_http (
  $contact_groups,
  $location
) inherits admin::nagios::global_nrpe {
  @@nagios_service { "check_http_${fqdn}":
    service_description => 'HTTP',
    check_command       => 'check_http',  
    contact_groups      => $contact_groups,
    tag                 => $location,
  }
}
