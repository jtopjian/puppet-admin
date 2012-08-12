class admin::nagios::contacts {
  # Use this to define contacts
  Nagios_contact {
    service_notification_period   => '24x7',
    host_notification_period      => '24x7',
    service_notification_options  => 'w,u,c,r',
    host_notification_options     => 'd,r',
    service_notification_commands => 'notify-service-by-email',
    host_notification_commands    => 'notify-host-by-email',
    target                        => '/etc/nagios3/conf.d/nagios_contacts.cfg',
  } 
  
  Nagios_contactgroup {
    target   => '/etc/nagios3/conf.d/nagios_contactgroups.cfg',
    require  => File['/etc/nagios3/conf.d/nagios_contactgroups.cfg'],
  }
  
  nagios_contact { 'jtopjian':
    email => 'joe.topjian@cybera.ca',
    alias => 'joe',
  }
  
  nagios_contactgroup { 'sysadmins':
    members => 'jtopjian',
    alias   => 'System Administrators',
  }
  
  nagios_contactgroup { 'oncall':
    members => 'jtopjian',
    alias   => 'On-call',
  }
}
