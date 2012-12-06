#
class admin::openstack::controller::dc2 {

  # Base configuration
  class { 'admin::openstack::controller::base': }

  # apache config specific to dc2
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
