# cloud configuration

class admin::cloud::controller {
  class { 'mysql::server::account_security': }

  class { 'openstack::controller':
    public_address        => hiera('cloud_public_ip'),
    public_interface      => hiera('public_interface'),
    private_interface     => hiera('private_interface'),
    internal_address      => hiera('cloud_private_ip'),
    mysql_root_password   => hiera('mysql_root_password'),
    rabbit_password       => hiera('rabbit_password'),
    admin_email           => hiera('keystone_admin_email'),
    admin_password        => hiera('keystone_admin_password'),
    keystone_db_password  => hiera('keystone_mysql_password'),
    keystone_admin_token  => hiera('keystone_admin_token'),
    glance_db_password    => hiera('glance_mysql_password'),
    glance_user_password  => hiera('glance_mysql_password'),
    nova_db_password      => hiera('nova_mysql_password'),
    nova_user_password    => hiera('nova_admin_password'),
    secret_key            => hiera('horizon_secret_key'),
    horizon_app_links     => hiera('horizon_app_links'),
    fixed_range           => hiera('fixed_range'),
    num_networks          => hiera('num_networks'),
    floating_range        => hiera('floating_range'),
    keystone_admin_tenant => hiera('keystone_admin_tenant'),
    verbose               => 'True',
    network_manager       => 'nova.network.manager.VlanManager',
    network_config        => {
        vlan_start => hiera('vlan_start'),
    },
  }

  class { 'openstack::auth_file': 
    admin_password       => hiera('keystone_admin_password'),
    keystone_admin_token => hiera('keystone_admin_token'),
    admin_tenant         => hiera('keystone_admin_tenant'),
  }

  # Misc options
  @@nova_config { 'metadata_host': value => hiera('private_ip') }
  @@nova_config { 'bindir':        value => '/usr/bin' }
  @@nova_config { 'libvirt_use_virtio_for_bridges': value => true }
  Nova_config <||>

  # Enpoints for other data centres
  $public_ip  = hiera('cloud_public_ip')
  $keystone_public_url = "http://${public_ip}:5000/v2.0"
  $keystone_admin_url  = "http://${public_ip}:35357/v2.0"
  keystone_endpoint { 'RegionTwo/keystone':
    public_url   => $keystone_public_url,
    admin_url    => $keystone_admin_url,
    internal_url => $keystone_public_url,
  }

  $glance_public_url = "http://199.116.232.18:9292/v1"
  keystone_endpoint { 'RegionTwo/glance':
    public_url   => $glance_public_url,
    admin_url    => $glance_public_url,
    internal_url => $glance_public_url,
  }
    

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
  $cloud_public_hostname = hiera('cloud_public_hostname')
  apache::vhost::redirect { $cloud_public_hostname:
    priority   => '1',
    port       => '80',
    dest       => "https://${cloud_public_hostname}",
  }

  apache::vhost { "default-${cloud_public_hostname}-ssl":
    priority   => '1',
    servername => hiera('cloud_public_hostname'),
    ssl        => true,
    port       => 443,
    docroot    => '/var/www',
  }

}

class admin::cloud::compute { 

  class { 'openstack::compute': 
    private_interface   => hiera('private_interface'),
    internal_address    => hiera('private_ip'),
    nova_user_password  => hiera('nova_admin_password'),
    rabbit_password     => hiera('rabbit_password'),
    vncproxy_host       => hiera('cloud_public_hostname'),
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
