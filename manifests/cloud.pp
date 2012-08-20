# cloud configuration

class admin::cloud::controller {
  class { 'mysql::server::account_security': }

  class { 'openstack::controller':
    public_address        => $::admin::params::cloud::controller_public_ip,
    public_interface      => $::admin::params::cloud::public_interface,
    private_interface     => $::admin::params::cloud::private_interface,
    internal_address      => $::admin::params::cloud::controller_private_ip,
    mysql_root_password   => $::admin::params::cloud::mysql_root_password,
    rabbit_password       => $::admin::params::cloud::rabbit_password,
    admin_email           => $::admin::params::cloud::keystone_admin_email,
    admin_password        => $::admin::params::cloud::keystone_admin_password,
    keystone_db_password  => $::admin::params::cloud::keystone_mysql_password,
    keystone_admin_token  => $::admin::params::cloud::keystone_admin_token,
    glance_db_password    => $::admin::params::cloud::glance_mysql_password,
    glance_user_password  => $::admin::params::cloud::glance_mysql_password,
    nova_db_password      => $::admin::params::cloud::nova_mysql_password,
    nova_user_password    => $::admin::params::cloud::nova_admin_password,
    secret_key            => $::admin::params::cloud::horizon_secret_key,
    horizon_app_links     => $::admin::params::cloud::horizon_app_links,
    fixed_range           => $::admin::params::cloud::fixed_range,
    num_networks          => $::admin::params::cloud::num_networks,
    floating_range        => $::admin::params::cloud::floating_range,
    keystone_admin_tenant => $::admin::params::cloud::keystone_admin_tenant,
    verbose               => 'True',
    network_manager       => 'nova.network.manager.VlanManager',
    network_config        => {
        vlan_start => $::admin::params::cloud::vlan_start,
    },
  }

  class { 'openstack::auth_file': 
    admin_password       => $::admin::params::cloud::keystone_admin_password,
    keystone_admin_token => $::admin::params::cloud::keystone_admin_token,
    admin_tenant         => $::admin::params::cloud::keystone_admin_tenant,
  }

  # Misc options
  @@nova_config { 'metadata_host': value => $::admin::params::cloud::private_ip }
  @@nova_config { 'bindir':        value => '/usr/bin' }
  @@nova_config { 'libvirt_use_virtio_for_bridges': value => true }
  Nova_config <||>

  # Nagios checks
  class { 'admin::nagios::check_mysql_nrpe': 
    contact_groups => ['sysadmins'],
  }
  admin::nagios::basic_proc_check_nrpe { 'keystone-all': 
    contact_groups => ['sysadmins'],
  }
  $glance_procs = ['glance-api', 'glance-registry']
  admin::nagios::basic_proc_check_nrpe { $glance_procs: 
    contact_groups => ['sysadmins'],
  }
  admin::nagios::basic_proc_check_nrpe { 'nova-network': 
    contact_groups => ['sysadmins'],
  }
  admin::nagios::basic_proc_check_nrpe { 'nova-scheduler': 
    contact_groups => ['sysadmins'],
  }
  admin::nagios::basic_proc_check_nrpe { 'nova-objectstore': 
    contact_groups => ['sysadmins'],
  }
  admin::nagios::basic_proc_check_nrpe { 'nova-api': 
    contact_groups => ['sysadmins'],
  }
  class { 'admin::nagios::check_http': 
    contact_groups => ['sysadmins'],
  }

  # Redirect all traffic to https
  apache::vhost::redirect { $::admin::params::cloud::controller_public_hostname:
    priority   => '1',
    port       => '80',
    dest       => "https://${::admin::params::cloud::controller_public_hostname}",
  }

  apache::vhost { "default-ssl-${::admin::params::cloud::controller_public_hostname}":
    priority   => '1',
    servername => $::admin::params::cloud::controller_public_hostname,
    ssl        => true,
    port       => 443,
    docroot    => '/var/www',
  }

}

class admin::cloud::compute { 

  class { 'openstack::compute': 
    private_interface   => $::admin::params::cloud::private_interface,
    internal_address    => $::admin::params::private_ip,
    nova_user_password  => $::admin::params::cloud::nova_admin_password,
    rabbit_password     => $::admin::params::cloud::rabbit_password,
    vncproxy_host       => $::admin::params::cloud::controller_public_hostname,
  }

  # Exported config - see cloud::controller
  Nova_config <<| title == 'rabbit_host' |>>
  Nova_config <<| title == 'sql_connection' |>>
  Nova_config <<| title == 'glance_api_servers' |>>

  # Nagios check
  admin::nagios::basic_proc_check_nrpe { 'nova-compute': 
    contact_groups => ['sysadmins'],
  }
  admin::nagios::basic_proc_check_nrpe { 'nova-volume': 
    contact_groups => ['sysadmins'],
  }
  class { 'admin::nagios::check_kvm-pegged_nrpe': 
    contact_groups => ['sysadmins'],
  }
} 
