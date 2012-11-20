# cloud configuration
class admin::openstack::controller::nova-ab {

  # Base configuration
  class { 'admin::openstack::controller::base': }

  ## Other Keystone endpoints
  # Add other keystone endpoints for Quebec region
  $ip = hiera('cloud_public_ip')
  keystone_endpoint { "quebec/keystone":
    ensure       => present,
    public_url   => "http://${ip}:5000/v2.0",
    admin_url    => "http://${ip}:35357/v2.0",
    internal_url => "http://${ip}:5000/v2.0",
  }

  keystone_endpoint { "quebec/glance":
    ensure       => present,
    public_url   => "http://${ip}:9292/v1",
    admin_url    => "http://${ip}:9292/v1",
    internal_url => "http://${ip}:9292/v1",
  }

  $quebec_ip = '208.75.75.10'
  keystone_endpoint { "quebec/cinder":
    ensure       => present,
    public_url   => "http://${quebec_ip}:8776/v1/%(tenant_id)s",
    admin_url    => "http://${quebec_ip}:8776/v1/%(tenant_id)s",
    internal_url => "http://${quebec_ip}:8776/v1/%(tenant_id)s",
  }

  keystone_endpoint { "quebec/nova":
    ensure       => present,
    public_url   => "http://${quebec_ip}:8774/v2/%(tenant_id)s",
    admin_url    => "http://${quebec_ip}:8774/v2/%(tenant_id)s",
    internal_url => "http://${quebec_ip}:8774/v2/%(tenant_id)s",
  }

  keystone_endpoint { "quebec/nova_ec2":
    ensure       => present,
    public_url   => "http://${quebec_ip}:8773/services/Cloud",
    admin_url    => "http://${quebec_ip}:8773/services/Admin",
    internal_url => "http://${quebec_ip}:8773/services/Cloud",
  }

  $quebec_swift = '208.75.75.250'
  keystone_endpoint { "quebec/swift":
    ensure       => present,
    public_url   => "https://${quebec_swift}:8080/v1/AUTH_%(tenant_id)s",
    admin_url    => "https://${quebec_swift}:8080/",
    internal_url => "https://${quebec_swift}:8080/v1/AUTH_%(tenant_id)s",
  }

  keystone_endpoint { "quebec/swift_s3":
    ensure       => present,
    public_url   => "https://${quebec_swift}:8080",
    admin_url    => "https://${quebec_swift}:8080",
    internal_url => "https://${quebec_swift}:8080",
  }

  # Apache specific for nova-ab
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
    ssl_cert   => '/etc/ssl/certs/nova-ab.dair-atir.canarie.ca.crt',
    ssl_key    => '/etc/ssl/private/nova-ab.dair-atir.canarie.ca.ins.key',
    ssl_intermediate => '/etc/ssl/certs/GeoTrust.pem',
  }

  file { '/etc/ssl/certs/nova-ab.dair-atir.canarie.ca.crt':
    ensure => present,
    source => 'puppet:///admin/ssl/nova-ab.dair-atir.canarie.ca.crt',
    before => Apache::Vhost["default-${cloud_public_hostname}-ssl"],
  }

  file { '/etc/ssl/private/nova-ab.dair-atir.canarie.ca.ins.key':
    ensure => present,
    source => 'puppet:///admin/ssl/nova-ab.dair-atir.canarie.ca.ins.key',
    before => Apache::Vhost["default-${cloud_public_hostname}-ssl"],
  }

  file { '/etc/ssl/certs/GeoTrust.pem':
    ensure => present,
    source => 'puppet:///admin/ssl/GeoTrust.pem',
    before => Apache::Vhost["default-${cloud_public_hostname}-ssl"],
  }

}
