#
class admin::openstack::compute::node {

  ## Nova
  # basic nova
  $glance_host = hiera('glance_host')
  class { 'nova':
    sql_connection     => hiera('nova_db'),
    rabbit_userid      => hiera('rabbit_user'),
    rabbit_password    => hiera('rabbit_password'),
    image_service      => 'nova.image.glance.GlanceImageService',
    glance_api_servers => "${glance_host}:9292",
    verbose            => 'True',
    rabbit_host        => hiera('cloud_public_ip'),
  }

  # Install / configure nova-compute
  class { 'nova::compute':
    vncserver_proxyclient_address => hiera('private_ip'),
    vncproxy_host                 => hiera('cloud_public_hostname'),
    vnc_enabled                   => true,
    enabled                       => true,
  }

  # Configure libvirt for nova-compute
  class { 'nova::compute::libvirt':
    libvirt_type      => hiera('libvirt_type'),
    vncserver_listen  => '0.0.0.0',
    migration_support => true,
  }

  # extra nova
  $cloud_private_ip = hiera('cloud_private_ip')
  nova_config {
    'cinder_endpoint_template': value => "http://${cloud_private_ip}:8776/v1/%(project_id)s";
    'volume_api_class':         value => 'nova.volume.cinder.API';
    'vlan_interface':           value => hiera('private_interface');
  }

  # Instances mountpoint
  $netapp = hiera('netapp')
  mount { '/var/lib/nova/instances':
    device  => "${netapp}:/vol/vol_openstack_instances/openstack_instances",
    fstype  => 'nfs',
    ensure  => 'mounted',
    options => 'nobootwait',
    atboot  => 'true',
  }

  ## syslog
  # nova
  nova_config {
    'use_syslog':          value => 'True';
    'syslog_log_facility': value => 'LOG_LOCAL0';
  }

  # cinder
  #cinder_config {
  #  'DEFAULT/use_syslog':          value => 'True';
  #  'DEFAULT/syslog_log_facility': value => 'LOG_LOCAL3';
  #}

  class { 'cinder::base':
    verbose         => 'True',
    sql_connection  => hiera('cinder_db'),
    rabbit_password => hiera('rabbit_password'),
  }

  #class { 'cinder::api':
  #  keystone_password  => hiera('cinder_keystone_password'),
  #  keystone_auth_host => hiera('keystone_host'),
  #  keystone_tenant    => 'services',
  #}

  # Nagios checks
  admin::nagios::basic_proc_check_nrpe { 'nova-compute':
    contact_groups => ['sysadmins'],
    location       => $::location,
  }
  class { 'admin::nagios::check_kvm-pegged_nrpe':
    contact_groups => ['sysadmins'],
    location       => $::location,
  }

}
