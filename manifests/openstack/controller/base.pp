# cloud configuration
class admin::openstack::controller::base {

  ## Glance
  # Install and configure glance-api
  class { 'glance::api':
    verbose           => 'True',
    debug             => 'True',
    auth_host         => hiera('keystone_host'),
    keystone_password => hiera('glance_keystone_password'),
    sql_connection    => hiera('glance_db'),
    keystone_tenant   => 'services',
    keystone_user     => 'glance',
  }

  # Install and configure glance-registry
  class { 'glance::registry':
    verbose           => 'True',
    debug             => 'True',
    auth_host         => hiera('keystone_host'),
    keystone_password => hiera('glance_keystone_password'),
    sql_connection    => hiera('glance_db'),
    keystone_tenant   => 'services',
    keystone_user     => 'glance',
  }

  # Configure file storage backend
  class { 'glance::backend::file': }

  ## Nova
  # Install / configure rabbitmq
  class { 'nova::rabbitmq':
    userid   => hiera('rabbit_user'),
    password => hiera('rabbit_password'),
  }

  # Configure Nova
  $glance_host = hiera('glance_host')
  class { 'nova':
    sql_connection     => hiera('nova_db'),
    rabbit_userid      => hiera('rabbit_user'),
    rabbit_password    => hiera('rabbit_password'),
    glance_api_servers => "${glance_host}:9292",
    verbose            => 'True',
    rabbit_host        => hiera('cloud_public_ip'),
  }

  # Configure nova-api
  class { 'nova::api':
    admin_password    => hiera('nova_admin_password'),
    auth_host         => hiera('keystone_host'),
    admin_tenant_name => 'services',
    enabled           => true,
  }

  # Configure nova-network
  class { 'nova::network':
    private_interface => hiera('private_interface'),
    public_interface  => hiera('public_interface'),
    fixed_range       => hiera('fixed_range'),
    network_manager   => 'nova.network.manager.VlanManager',
    num_networks      => 850,
    enabled           => true,
    config_overrides  => {
      'vlan_start' => hiera('vlan_start'),
    },
  }

  # a bunch of nova services that require no configuration
  class { [
    'nova::scheduler',
    'nova::objectstore',
    'nova::cert',
    'nova::consoleauth'
   ]:
     enabled => true,
  }

  # extra nova
  $cloud_private_ip = hiera('cloud_private_ip')
  nova_config {
    'cinder_endpoint_template': value => "http://${cloud_private_ip}:8776/v1/%(project_id)s";
    'ram_allocation_ratio':     value => 4;
  }

  # Configure VNC
  class { 'nova::vncproxy':
     host    => hiera('cloud_public_ip'),
     enabled => true,
  }

  ## Cinder
  # base
  class { 'cinder::base':
    verbose         => 'True',
    sql_connection  => hiera('cinder_db'),
    rabbit_password => hiera('rabbit_password'),
  }

  # cinder api
  class { 'cinder::api':
    keystone_password  => hiera('cinder_keystone_password'),
    keystone_auth_host => hiera('keystone_host'),
    keystone_tenant    => 'services',
  }

  # cinder scheduler
  class { 'cinder::scheduler': }

  # NetApp Configuration
  class { 'cinder::volume': }
  class { 'cinder::volume::netapp':
    netapp_wsdl_url        => hiera('netapp_wsdl_url'),
    netapp_login           => hiera('netapp_login'),
    netapp_password        => hiera('netapp_password'),
    netapp_server_hostname => hiera('netapp_server_hostname'),
    netapp_storage_service => hiera('netapp_storage_service'),
  }

  ## Horizon
  class { 'openstack::horizon':
    secret_key        => hiera('horizon_secret_key'),
    horizon_app_links => hiera('horizon_app_links'),
    swift             => true,
    quantum           => false,
  }

  ## syslog
  # nova
  nova_config {
    'use_syslog':          value => 'True';
    'syslog_log_facility': value => 'LOG_LOCAL0';
  }

  # glance
  glance_api_config {
    'DEFAULT/use_syslog':          value => 'True';
    'DEFAULT/syslog_log_facility': value => 'LOG_LOCAL1';
  }

  # keystone
  keystone_config {
    'DEFAULT/use_syslog':          value => 'True';
    'DEFAULT/syslog_log_facility': value => 'LOG_LOCAL2';
  }

  # cinder
  cinder_config {
    'DEFAULT/use_syslog':          value => 'True';
    'DEFAULT/syslog_log_facility': value => 'LOG_LOCAL3';
  }

  ## Generate an openrc file
  class { 'openstack::auth_file':
    controller_node      => hiera('keystone_public_ip'),
    admin_password       => hiera('keystone_admin_password'),
    keystone_admin_token => hiera('keystone_admin_token'),
    admin_tenant         => hiera('keystone_admin_tenant'),
    region               => $::location,
  }

  ## Nagios checks
  class { 'admin::nagios::check_mysql_nrpe':
    contact_groups => ['sysadmins'],
    location       => $::location,
  }
  admin::nagios::basic_proc_check_nrpe { 'keystone-all':
    contact_groups => ['sysadmins'],
    location       => $::location,
  }
  $glance_procs = ['glance-api', 'glance-registry']
  admin::nagios::basic_proc_check_nrpe { $glance_procs:
    contact_groups => 'sysadmins',
    location       => $::location,
  }
  admin::nagios::basic_proc_check_nrpe { 'nova-network':
    contact_groups => 'sysadmins',
    location       => $::location,
  }
  admin::nagios::basic_proc_check_nrpe { 'nova-scheduler':
    contact_groups => 'sysadmins',
    location       => $::location,
  }
  admin::nagios::basic_proc_check_nrpe { 'nova-objectstore':
    contact_groups => 'sysadmins',
    location       => $::location,
  }
  admin::nagios::basic_proc_check_nrpe { 'nova-api':
    contact_groups => 'sysadmins',
    location       => $::location,
  }
  class { 'admin::nagios::check_http':
    contact_groups => 'sysadmins',
    location       => $::location,
  }

  # oncommand
  $oncommand_ip    = hiera('oncommand')
  $oncommand_name = "oncommand-${::location}"
  nagios_host { $oncommand_name:
    address        => $oncommand_ip,
    use            => 'generic-host',
    contact_groups => 'sysadmins',
    tag            => $::location,
    target         => '/etc/nagios3/conf.d/nagios_hosts.cfg',
    require        => File['/etc/nagios3/conf.d/nagios_hosts.cfg'],
  }

}
