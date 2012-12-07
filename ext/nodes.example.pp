# Config that gets applied to all servers
node base {

  class { 'ntp': }
  class { 'stdlib': }
  class { 'admin::mail::aliases': }
  class { 'admin::security-updates': }
  class { 'admin::fail2ban':                     ignore_networks => hiera('fail2ban_ignore_networks') }
  class { 'admin::nagios::nrpe':                 allowed_hosts   => hiera('nrpe_allowed_hosts') }
  class { 'admin::rclocal::base': }
  class { 'admin::rclocal::bootmail': }
  class { 'admin::nagios::basic_host_checks':    
    contact_groups  => 'oncall',
    location        => $::location,
  }
  class { 'admin::nagios::basic_service_checks': 
    contact_groups  => 'sysadmins',
    location        => $::location,
  }

  admin::functions::enable_ssh_key { 'util': 
    user => 'root', 
    key  => hiera('ssh_util_admin_key'),
  }

  admin::functions::enable_ssh_key { 'cloud': 
    user => 'root', 
    key  => hiera('ssh_cloud_admin_key'),
  }

  Host <<| tag == 'all' |>>
  Host <<| tag == $::location |>>
}

# Config for a "basic" server - basically any server that doesn't require
# a very specific configuration
node basic_server inherits base {
  class { 'admin::basepackages': }
  class { 'admin::puppet::agent':
    puppet_server => hiera('puppet_server'),
    version       => 'latest',
  }
  class { 'admin::apt-cacher-ng::client': server         => hiera('puppet_server') }
  class { 'admin::mail::postfix':         relayhost      => hiera('postfix_relay_host') }
  class { 'admin::rsyslog::client':       rsyslog_server => hiera('rsyslog_server') }

  admin::functions::add_host { $::fqdn:
    ip       => hiera('private_ip'),
    aliases  => [$::hostname],
    location => $::location, 
  }
}

# A "public" server is one that needs a public and private host entry
node public_server inherits base { 
  class { 'admin::basepackages': } 
  class { 'admin::puppet::agent': 
    puppet_server  => hiera('puppet_server'), 
    version        => 'latest', 
  } 
  class { 'admin::apt-cacher-ng::client': server         => hiera('util_private_ip') }
  class { 'admin::rsyslog::client':       rsyslog_server => hiera('rsyslog_server') }

  admin::functions::add_host { $::fqdn:
    ip       => hiera('public_ip'),    
    aliases  => [$::hostname],         
    location => 'all',                 
  }                                    
}

# A public master server is one that will relay mail and collect
# logs on behalf of other servers around it                     
node public_master_server inherits base {                       
  class { 'admin::basepackages': }                              
  class { 'admin::puppet::agent':                               
    puppet_server  => hiera('puppet_server'),                   
    version        => 'latest',                                 
  }                                                             
                                                                
  admin::functions::add_host { $::fqdn:                         
    ip       => hiera('public_ip'),                             
    aliases  => [$::hostname],                                  
    location => 'all',                                          
  }                                                             
                                                                
  # Mail server                                                 
  class { 'admin::mail::postfix':                               
    my_networks => hiera('postfix_my_networks'),                
  }                                                             
                                                                
  # rsyslog                                                     
  class { 'admin::rsyslog::server':                             
    interface        => hiera('private_ip'),                    
  }                                                             

  # Nagios server                                    
  class { 'admin::nagios::server':                   
    admin_password => hiera('nagios_admin_password'),
    location       => $::location,                   
  }                                                  
                                                     
  # Firewall                                         
  class { 'admin::rclocal::firewall': }              
}

# Utility Server
node 'puppet.dc1.sandbox.cybera.ca' inherits base {
  Host <<| tag == $::location |>>
  class { 'admin::basepackages': }
  class { 'admin::backups::mysql': }
  class { 'admin::util-server':
    util_public_hostname         => hiera('util_public_hostname'),
    mysql_root_password          => hiera('mysql_root_password'),
    puppet_dashboard_user        => hiera('puppet_dashboard_user'),
    puppet_dashboard_password    => hiera('puppet_dashboard_password'),
    puppet_dashboard_site        => hiera('util_public_hostname'),
    cobbler_dhcp_start_range     => hiera('cobbler_dhcp_start_range'),
    cobbler_dhcp_stop_range      => hiera('cobbler_dhcp_stop_range'),
    cobbler_next_server          => hiera('cobbler_next_server'),
    cobbler_server               => hiera('cobbler_server'),
    cobbler_password             => hiera('cobbler_password'),
    postfix_my_networks          => hiera('postfix_my_networks'),
  }

  class { 'admin::nagios::check_mysql_nrpe': 
    contact_groups => 'sysadmins', 
    location       => $::location,
  }

  $public_hostname  = hiera('util_public_hostname')
  $private_hostname = hiera('util_private_hostname')
  admin::functions::add_host { $public_hostname:
    ip       => hiera('util_public_ip'),
    aliases  => [$::hostname],
    location => 'all'
  }

  admin::functions::add_host { $private_hostname:
    ip       => hiera('util_private_ip'),
    location => 'dc1'
  }

}

# Cloud Controllers                                                                                 
node 'cloud.dc1.sandbox.cybera.ca' inherits public_master_server {
  ## Configure to be a cloud controller                                                             
  # order                                                                                           
  Class['admin::openstack::controller::mysql']    -> Class['admin::openstack::controller::keystone']
  Class['admin::openstack::controller::keystone'] -> Class['admin::openstack::controller::dc1']
  # apply roles 
  class { 'admin::openstack::controller::mysql': } 
  class { 'admin::openstack::controller::keystone': } 
  class { 'admin::openstack::controller::dc1': } 

}

# Compute Nodes
node 'c01.dc1.sandbox.cybera.ca',
     'c02.dc1.example.com'  inherits basic_server {
  class { 'admin::openstack::compute::node': }
}
