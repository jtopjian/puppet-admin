# cloud configuration
class admin::openstack::controller::dc1 {

  # Base configuration
  class { 'admin::openstack::controller::base': }

  # build a mysqlrc file for all mysql servers
  class { 'admin::mysql::mysqlrc': 
    comment => 'master',
  }

  ## Other Keystone endpoints
  # Add other keystone endpoints for Quebec region
  $ip = hiera('cloud_public_ip')
  keystone_endpoint { "dc2/keystone":
    ensure       => present,
    public_url   => "http://${ip}:5000/v2.0",
    admin_url    => "http://${ip}:35357/v2.0",
    internal_url => "http://${ip}:5000/v2.0",
  }

  keystone_endpoint { "dc2/glance":
    ensure       => present,
    public_url   => "http://${ip}:9292/v1",
    admin_url    => "http://${ip}:9292/v1",
    internal_url => "http://${ip}:9292/v1",
  }

  $dc2_ip = '208.75.75.10'
  keystone_endpoint { "dc2/cinder":
    ensure       => present,
    public_url   => "http://${dc2_ip}:8776/v1/%(tenant_id)s",
    admin_url    => "http://${dc2_ip}:8776/v1/%(tenant_id)s",
    internal_url => "http://${dc2_ip}:8776/v1/%(tenant_id)s",
  }

  keystone_endpoint { "dc2/nova":
    ensure       => present,
    public_url   => "http://${dc2_ip}:8774/v2/%(tenant_id)s",
    admin_url    => "http://${dc2_ip}:8774/v2/%(tenant_id)s",
    internal_url => "http://${dc2_ip}:8774/v2/%(tenant_id)s",
  }

  keystone_endpoint { "dc2/nova_ec2":
    ensure       => present,
    public_url   => "http://${dc2_ip}:8773/services/Cloud",
    admin_url    => "http://${dc2_ip}:8773/services/Admin",
    internal_url => "http://${dc2_ip}:8773/services/Cloud",
  }

  $dc2_swift = '208.75.75.250'
  keystone_endpoint { "dc2/swift":
    ensure       => present,
    public_url   => "https://${dc2_swift}:8080/v1/AUTH_%(tenant_id)s",
    admin_url    => "https://${dc2_swift}:8080/",
    internal_url => "https://${dc2_swift}:8080/v1/AUTH_%(tenant_id)s",
  }

  keystone_endpoint { "dc2/swift_s3":
    ensure       => present,
    public_url   => "https://${dc2_swift}:8080",
    admin_url    => "https://${dc2_swift}:8080",
    internal_url => "https://${dc2_swift}:8080",
  }

  # Apache specific for dc1
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
