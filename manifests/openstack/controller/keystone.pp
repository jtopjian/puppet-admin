# keystone configuration
class admin::openstack::controller::keystone {
  ## Keystone
  class { '::keystone':
    verbose        => 'True',
    debug          => 'True',
    catalog_type   => 'sql',
    admin_token    => hiera('keystone_admin_token'),
    sql_connection => hiera('keystone_db'),
    enabled        => true,
  }

  # Setup the admin user
  class { 'keystone::roles::admin':
    email        => 'root@localhost',
    password     => hiera('keystone_admin_password'),
    admin_tenant => hiera('keystone_admin_tenant'),
  }

  # Setup the Keystone Identity Endpoint
  class { 'keystone::endpoint':
    public_address   => hiera('keystone_host'),
    admin_address    => hiera('keystone_host'),
    internal_address => hiera('keystone_host'),
    region           => $::location,
  }

  # Configure Glance endpoint in Keystone
  class { 'glance::keystone::auth':
    password         => hiera('glance_keystone_password'),
    public_address   => hiera('keystone_host'),
    admin_address    => hiera('keystone_host'),
    internal_address => hiera('keystone_host'),
    region           => $::location,
  }

  # Configure Nova endpoint in Keystone
  class { 'nova::keystone::auth':
    password         => hiera('nova_keystone_password'),
    public_address   => hiera('cloud_public_ip'),
    admin_address    => hiera('cloud_public_ip'),
    internal_address => hiera('cloud_public_ip'),
    cinder           => true,
    region           => $::location,
  }

  # Configure Nova endpoint in Keystone
  class { 'cinder::keystone::auth':
    password         => hiera('cinder_keystone_password'),
    public_address   => hiera('cloud_public_ip'),
    admin_address    => hiera('cloud_public_ip'),
    internal_address => hiera('cloud_public_ip'),
    region           => $::location,
  }

  # Configure Swift endpoint in Keystone
  class { 'swift::keystone::auth':
    password => hiera('swift_keystone_password'),
    address  => hiera('swift_public_ip'),
    region   => $::location,
    protocol => 'https',
  }
}
