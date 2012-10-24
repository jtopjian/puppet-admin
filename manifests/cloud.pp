# cloud configuration

class admin::cloud::controller {

  class { 'openstack::controller':
    # Network
    network_manager        => 'nova.network.manager.VlanManager',
    public_address         => hiera('cloud_public_ip'),
    public_interface       => hiera('public_interface'),
    private_interface      => hiera('private_interface'),
    fixed_range            => hiera('fixed_range'),
    floating_range         => hiera('floating_range'),
    num_networks           => hiera('num_networks'),
    network_config         => {
      'vlan_start' => hiera('vlan_start'),
    },
    # Database
    db_type                => 'mysql',
    mysql_account_security => true,
    db_host                => hiera('cloud_mysql_host'),
    mysql_root_password    => hiera('mysql_root_password'),
    allowed_hosts          => hiera('mysql_allowed_hosts'),
    # Keystone
    admin_email            => hiera('keystone_admin_email'),
    admin_password         => hiera('keystone_admin_password'),
    keystone_db_password   => hiera('keystone_mysql_password'),
    keystone_admin_token   => hiera('keystone_admin_token'),
    keystone_admin_tenant  => hiera('keystone_admin_tenant'),
    region                 => hiera('region'),
    # Glance
    glance_db_password     => hiera('glance_mysql_password'),
    glance_user_password   => hiera('glance_keystone_password'),
    glance_api_servers     => hiera('glance_api_servers'),
    # Nova
    nova_db_password       => hiera('nova_mysql_password'),
    nova_user_password     => hiera('nova_keystone_password'),
    purge_nova_config      => false,
    # cinder
    cinder_db_password     => hiera('cinder_mysql_password'),
    cinder_user_password   => hiera('cinder_keystone_password'),
    # Rabbit
    rabbit_password        => hiera('rabbit_password'),
    rabbit_user            => hiera('rabbit_user'),
    # Horizon
    secret_key             => hiera('horizon_secret_key'),
    cache_server_ip        => '127.0.0.1',
    cache_server_port      => '11211',
    horizon_app_links      => hiera('horizon_app_links'),
    swift                  => false,
    quantum                => false,
    cinder                 => true,
    # General
    verbose                => 'True',
  }

  # Scheduler options
  nova_config { 'scheduler_default_filters': value => 'AvailabilityZoneFilter' }

  # Admin / test files
  class { 'openstack::test_file': }

  class { 'openstack::auth_file': 
    admin_password       => hiera('keystone_admin_password'),
    keystone_admin_token => hiera('keystone_admin_token'),
    admin_tenant         => hiera('keystone_admin_tenant'),
  }

  # Cinder - should be on a compute node
  #class { 'cinder::volume': }
  #class { 'cinder::volume::iscsi': }


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
    quantum               => false,
    glance_api_servers    => hiera('glance_api_servers'),
    sql_connection        => hiera('nova_db'),
    internal_address      => hiera('private_ip'),
    nova_user_password    => hiera('nova_keystone_password'),
    rabbit_password       => hiera('rabbit_password'),
    rabbit_host           => hiera('cloud_private_ip'),
    cinder_sql_connection => hiera('cinder_db'),
    vncproxy_host         => hiera('cloud_public_hostname'),
    libvirt_type          => hiera('libvirt_type'),
    migration_support     => true,
    vncserver_listen      => '0.0.0.0',
    nova_volume           => 'nova-volumes',
  }

  nova_config { 'vlan_interface': value => hiera('private_interface') }


} 
