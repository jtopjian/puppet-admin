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
    cinder                 => true,
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
    quantum                => false,
    # Swift
    swift                  => true,
    swift_public_address   => hiera('swift_public_ip'),
    swift_user_password    => hiera('swift_keystone_password'),
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

  # Make horizon the root
  file_line { 'horizon root':
    path => '/etc/apache2/conf.d/openstack-dashboard.conf',
    line => 'WSGIScriptAlias / /usr/share/openstack-dashboard/openstack_dashboard/wsgi/django.wsgi',
    match => 'WSGIScriptAlias ',
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
    nova_volume           => 'cinder-volumes',
  }

  nova_config { 'vlan_interface': value => hiera('private_interface') }

} 

class admin::cloud::swift_base {
  class { 'swift':
    swift_hash_suffix => hiera('swift_hash_suffix'),
  }
  class { 'ssh': }
}

class admin::cloud::swift_proxy inherits admin::cloud::swift_base {

  class { 'memcached':
    listen_ip => '127.0.0.1',
  }

  class { 'swift::proxy':
    account_autocreate => true,
    proxy_local_net_ip => hiera('public_ip'),
    pipeline           => ['healthcheck', 'cache', 'swift3', 'authtoken', 'keystone', 'proxy-logging', 'proxy-server'],
    require            => Class['swift::ringbuilder'],
  }
    
  class { 'swift::proxy::keystone':
    operator_roles => ['admin', 'Member', 'swiftoperator'],
  }

  class { 'swift::proxy::authtoken':
    auth_host      => hiera('keystone_public_hostname'),
    admin_password => hiera('swift_keystone_password'),
  }

  class { 'swift::proxy::healthcheck': }
  class { 'swift::proxy::cache': }
  class { 'swift::proxy::swift3': }
  class { 'swift::proxy::proxy-logging': }
  class { 'swift::proxy::s3token': 
    auth_host => hiera('keystone_public_hostname'),
  }

  # collect all of the resources that are needed
  # to balance the ring
  Ring_object_device <<||>>
  Ring_container_device <<||>>
  Ring_account_device <<||>>

  # create the ring
  class { 'swift::ringbuilder':
    # the part power should be determined by assuming 100 partitions per drive
    part_power     => '18',
    replicas       => '3',
    min_part_hours => 1,
    require        => Class['swift'],
  }

  # sets up an rsync db that can be used to sync the ring DB
  class { 'swift::ringserver':
    local_net_ip => hiera('private_ip'),
  }

  # exports rsync gets that can be used to sync the ring files
  @@swift::ringsync { ['account', 'object', 'container']:
   ring_server => hiera('private_ip'),
 }

  # deploy a script that can be used for testing
  file { '/tmp/swift_keystone_test.rb':
    source => 'puppet:///modules/swift/swift_keystone_test.rb'
  }
    
}

class admin::cloud::swift_node (
  $swift_zone
) inherits admin::cloud::swift_base {
  swift::storage::xfs { ['sda6', 'sdb6', 'sdc', 'sdd', 'sde', 'sdf']: }

  # install all swift storage servers together
  class { 'swift::storage::all':
    storage_local_net_ip => hiera('private_ip'),
  }

  $ip = hiera('private_ip')
  # specify endpoints per device to be added to the ring specification
  @@ring_object_device { 
    ["${ip}:6000/sda6",
     "${ip}:6000/sdb6",
     "${ip}:6000/sdc",
     "${ip}:6000/sdd",
     "${ip}:6000/sde",
     "${ip}:6000/sdf"]:
       zone   => $swift_zone,
       weight => 1,
  }

  @@ring_container_device { 
    ["${ip}:6001/sda6",
     "${ip}:6001/sdb6",
     "${ip}:6001/sdc",
     "${ip}:6001/sdd",
     "${ip}:6001/sde",
     "${ip}:6001/sdf"]:
       zone   => $swift_zone,
       weight => 1,
  }

  @@ring_account_device {
    ["${ip}:6002/sda6",
     "${ip}:6002/sdb6",
     "${ip}:6002/sdc",
     "${ip}:6002/sdd",
     "${ip}:6002/sde",
     "${ip}:6002/sdf"]:
       zone   => $swift_zone,
       weight => 1,
  }

  # collect resources for synchronizing the ring databases
  Swift::Ringsync<<||>>
}

