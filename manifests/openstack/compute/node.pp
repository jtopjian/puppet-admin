#
class admin::openstack::compute::node {

  ## Nova
  # basic nova
  class { 'nova':
    sql_connection     => hiera('nova_db'),
    rabbit_userid      => hiera('rabbit_user'),
    rabbit_password    => hiera('rabbit_password'),
    image_service      => 'nova.image.glance.GlanceImageService',
    glance_api_servers => hiera('glance_api_servers'),
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
    'volume_api_class':         value => 'nova.volume.cinder.API';
    'vlan_interface':           value => hiera('private_interface');
  }

  # Ensure libvirtu uuid's are unique     
  class { 'admin::fixes::libvirtd_uuid': }

  ## syslog
  # nova
  nova_config {
    'use_syslog':          value => 'True';
    'syslog_log_facility': value => 'LOG_LOCAL0';
  }

  # cinder
  cinder_config {
    'DEFAULT/use_syslog':          value => 'True';
    'DEFAULT/syslog_log_facility': value => 'LOG_LOCAL3';
  }

  class { 'cinder::base':
    verbose         => 'True',
    sql_connection  => hiera('cinder_db'),
    rabbit_password => hiera('rabbit_password'),
    rabbit_host     => hiera('cloud_private_ip'),
  }

  class { 'cinder::api':
    keystone_password  => hiera('cinder_keystone_password'),
    keystone_auth_host => hiera('keystone_public_hostname'),
    keystone_tenant    => 'services',
  }

  class { 'cinder::volume': }
  class { 'cinder::volume::iscsi': 
    volume_group     => 'cinder-volumes',
    iscsi_ip_address => $::ipaddress_vlan30,
  }

  ## notifications
  nova_config {
    'notification_driver':         value => 'nova.openstack.common.notifier.rabbit_notifier';
    'notification_topics':         value => 'monitor';
    'instance_usage_audit_period': value => 'hour';
    'instance_usage_audit':        value => 'True';
  }

  cinder_config {
    'DEFAULT/notification_driver': value => 'cinder.openstack.common.notifier.rabbit_notifier';
    'DEFAULT/notification_topics': value => 'monitor';
    'DEFAULT/control_exchange':    value => 'nova';
  }

  # Nagios checks
  admin::nagios::basic_proc_check_nrpe { 'nova-compute':
    contact_groups => ['sysadmins'],
    location       => $::location,
  }
  class { 'admin::nagios::check_kvm-pegged_nrpe':
    contact_groups => ['sysadmins'],
    location       => $::location,
  }

  # GlusterFS
  class { 'admin::openstack::compute::glusterfs': }

  # Extra programs
  $packages = ['xfsprogs']
  package { $packages:
    ensure => installed,
  }

}
