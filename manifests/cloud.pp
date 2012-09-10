# cloud configuration

class admin::cloud::controller {

  #
  # MySQL and Databases
  #

  # Setup MySQL Server
  class { 'mysql::server':
    config_hash => {
      'root_password' => $::admin::params::cloud::mysql_root_password,
      'bind_address' => '0.0.0.0',
    }
  }

  # Configure base MySQL securely
  class { 'mysql::server::account_security': }

  # Configure backups for MySQL
  class { 'admin::backups::mysql': }

  # Create MySQL DB for Nova
  class { 'nova::db::mysql':
    user          => $::admin::params::cloud::nova_mysql_user,
    password      => $::admin::params::cloud::nova_mysql_password,
    dbname        => $::admin::params::cloud::nova_mysql_dbname,
    allowed_hosts => $::admin::params::cloud::mysql_allowed_hosts,
  }

  # Create MySQL DB for Keystone
  class { 'keystone::db::mysql':
    user          => $::admin::params::cloud::keystone_mysql_user,
    password      => $::admin::params::cloud::keystone_mysql_password,
    dbname        => $::admin::params::cloud::keystone_mysql_dbname,
    allowed_hosts => $::admin::params::cloud::mysql_allowed_hosts,
  }

  # Create MySQL DB for Glance
  class { 'glance::db::mysql':
    user          => $::admin::params::cloud::glance_mysql_user,
    password      => $::admin::params::cloud::glance_mysql_password,
    dbname        => $::admin::params::cloud::glance_mysql_dbname,
    allowed_hosts => $::admin::params::cloud::mysql_allowed_hosts,
  }
 
  # Create MySQL DB for Quantum
  class { 'quantum::db::mysql':
    user          => $::admin::params::cloud::quantum_mysql_user,
    password      => $::admin::params::cloud::quantum_mysql_password,
    dbname        => $::admin::params::cloud::quantum_mysql_dbname,
    allowed_hosts => $::admin::params::cloud::mysql_allowed_hosts,
  }

  # Create MySQL DB for Cinder
  class { 'cinder::db::mysql':
    user          => $::admin::params::cloud::cinder_mysql_user,
    password      => $::admin::params::cloud::cinder_mysql_password,
    dbname        => $::admin::params::cloud::cinder_mysql_dbname,
    allowed_hosts => $::admin::params::cloud::mysql_allowed_hosts,
  }

  # Initial Database Creations
  class { 'keystone::db::sync': }
  class { 'glance::db::sync': }
  class { 'nova::db::sync': }
  class { 'cinder::db::sync': }

  # Ensure that the correct settings are available for the database syncs
  Class['nova']     -> Class['nova::db::sync']
  Class['keystone'] -> Class['keystone::db::sync']
  Class['cinder']   -> Class['cinder::db::sync']
  Class['glance']   -> Class['glance::db::sync']

  #
  # Keystone
  #

  # Keystone settings
  $keystone_settings = {
    'DEFAULT' => {
      'verbose'     => 'true',
      'debug'       => 'true',
      'admin_token' => $::admin::params::cloud::keystone_admin_token,
    },
    'sql' => {
      'connection' => $::admin::params::cloud::keystone_db,
    }
  }

  # Install Keystone
  class { 'keystone':
    keystone_settings => $keystone_settings,
  }

  # Setup the Admin Keystone user
  class { 'keystone::roles::admin':
    email        => $::admin::params::cloud::keystone_admin_email,
    password     => $::admin::params::cloud::keystone_admin_password,
    admin_tenant => $::admin::params::cloud::keystone_admin_tenant,
  }

  # Setup Keystone Identity endpoint
  class { 'keystone::endpoint':
    public_address   => $::admin::params::cloud::controller_public_ip,
    admin_address    => $::admin::params::cloud::controller_public_ip,
    internal_address => $::admin::params::cloud::controller_public_ip,
  }

  # Configure Glance to use Keystone for auth
  class { 'glance::keystone::auth':
    password => $::admin::params::cloud::glance_keystone_password,
    public_address   => $::admin::params::cloud::controller_public_ip,
    admin_address    => $::admin::params::cloud::controller_public_ip,
    internal_address => $::admin::params::cloud::controller_public_ip,
  }

  # Setup Nova endpoint
  class { 'nova::keystone::auth':
    password         => $::admin::params::cloud::nova_admin_password,
    public_address   => $::admin::params::cloud::controller_public_ip,
    admin_address    => $::admin::params::cloud::controller_public_ip,
    internal_address => $::admin::params::cloud::controller_public_ip,
  }

  # Setup Quantum endpoint
  class { 'quantum::keystone::auth':
    password         => $::admin::params::cloud::quantum_keystone_password,
    public_address   => $::admin::params::cloud::controller_public_ip,
    admin_address    => $::admin::params::cloud::controller_public_ip,
    internal_address => $::admin::params::cloud::controller_public_ip,
  }

  # Setup Cinder endpoint
  class { 'cinder::keystone::auth':
    password => $::admin::params::cloud::cinder_keystone_password,
    public_address   => $::admin::params::cloud::controller_public_ip,
    admin_address    => $::admin::params::cloud::controller_public_ip,
    internal_address => $::admin::params::cloud::controller_public_ip,
  }

  # 
  # Glance
  #

  # Glance settings
  $glance_settings = {
    'DEFAULT' => {
      'debug'          => 'true',
      'verbose'        => 'true',
      'sql_connection' => $::admin::params::cloud::glance_db,
    }
  }

  # Install / Configure glance-api
  class { 'glance::api':
    keystone_password => $::admin::params::cloud::glance_keystone_password,
    api_settings      => $glance_settings,
  }

  # Install / Configure glance-registry
  class { 'glance::registry':
    keystone_password => $::admin::params::cloud::glance_keystone_password,
    registry_settings => $glance_settings,
  }

  #
  # Nova
  #

  # Nova settings
  $nova_settings = {
    'DEFAULT' => {
      'verbose'                   => 'true',
      'debug'                     => 'true',
      'ec2_dmz_host'              => $::admin::params::cloud::controller_private_ip,
      'metadata_host'             => $::admin::params::cloud::controller_private_ip,
      'enabled_apis'              => 'ec2,osapi_compute,metadata',
      'compute_scheduler_driver'  => 'nova.scheduler.filter_scheduler.FilterScheduler',
      'sql_connection'            => $::admin::params::cloud::nova_db,
      'image_service'             => 'nova.image.glance.GlanceImageService',
      'rabbit_host'               => $::admin::params::cloud::rabbit_host,
      'rabbit_userid'             => $::admin::params::cloud::rabbit_user,
      'rabbit_password'           => $::admin::params::cloud::rabbit_password,
      'routing_source_ip'         => $::admin::params::cloud::controller_private_ip,
      'bindir'                    => '/usr/bin',
      'glance_api_servers'        => "${::admin::params::cloud::controller_private_ip}:9292",
      'volume_api_class'          => 'nova.volume.cinder.API',
      'novnc_enable'              => 'true',
      'novncproxy_base_url'       => "http://${::admin::params::cloud::controller_private_ip}:6080/vnc_auto.html",
      'quantum_use_dhcp'          => 'true',
      'network_api_class'         => 'nova.network.quantumv2.api.API',
      'libvirt_vif_type'          => 'ethernet',
      'quantum_admin_username'    => 'quantum',
      'quantum_admin_password'    => $::admin::params::cloud::quantum_keystone_password,
      'quantum_admin_auth_url'    => "http://${::admin::params::cloud::keystone_host}:35357/v2.0",
      'quantum_auth_strategy'     => 'keystone',
      'quantum_admin_tenant_name' => 'services',
      'quantum_url'               => "http://${::admin::params::cloud::controller_private_ip}:9696",
      'nova_vif_driver'           => 'nova.virt.libvirt.vif.LibvirtHybridOVSBridgeDriver',
      'linuxnet_interface_driver' => 'nova.network.linux_net.LinuxOVSInterfaceDriver',
      'public_interface'          => $::admin::params::cloud::public_interface,
    }
  }

  # Configure Nova
  class { 'nova':
    nova_settings     => $nova_settings,
    keystone_password => $::admin::params::cloud::nova_admin_password,
  }

  # Configure RabbitMQ
  class { 'nova::rabbitmq':
    userid   => $::admin::params::cloud::rabbit_user,
    password => $::admin::params::cloud::rabbit_password,
  }

  # Configure other Nova services
  class { ['nova::api', 
           'nova::scheduler', 
           'nova::objectstore', 
           'nova::cert', 
           'nova::vncproxy', 
           'nova::consoleauth']:
    enabled => true,
  }
  
  # 
  # Quantum
  #

  # Quantum settings
  $quantum_settings = {
    'DEFAULT' => {
      'verbose'          => 'true',
      'debug'            => 'true',
      'control_exchange' => 'quantum',
      'fake_rabbit'      => 'false',
      'rabbit_password'  => $::admin::params::cloud::rabbit_password,
      'rabbit_host'      => 'localhost',
      'rabbit_userid'    => $::admin::params::cloud::rabbit_user,
    }
  }
  $quantum_dhcp_settings = {
    'DEFAULT' => {
      'verbose'          => 'true',
      'debug'            => 'true',
      'db_connection'    => $::admin::params::cloud::quantum_db,
      'interface_driver' => 'quantum.agent.linux.interface.OVSInterfaceDriver',
    }
  }
  $quantum_l3_settings = {
    'DEFAULT' => {
      'verbose' => 'true', 
      'debug'   => 'true',
      'db_connection' => $::admin::params::cloud::quantum_db,
      'interface_driver' => 'quantum.agent.linux.interface.OVSInterfaceDriver',
      'external_network_bridge' => 'br-ext',
    }
  }

  # Configure Quantum
  class { 'quantum':
    quantum_settings  => $quantum_settings,
    keystone_password => $::admin::params::cloud::quantum_keystone_password,
  }
  class { 'quantum::dhcp':
    dhcp_settings     => $quantum_dhcp_settings,
    keystone_password => $::admin::params::cloud::quantum_keystone_password,
  }
  class { 'quantum::l3':
    l3_settings       => $quantum_l3_settings,
    keystone_password => $::admin::params::cloud::quantum_keystone_password,
  }

  # Configure Open vSwitch for Quantum
  $ovs_settings = {
    'DATABASE' => {
      'sql_connection' => $::admin::params::cloud::quantum_db,
    },
    'OVS' => {
      'bridge_mappings'     => 'default:br-int',
      'network_vlan_ranges' => 'default:100:500',
      'core_plugin'         => 'quantum.plugins.openvswitch.ovs_quantum_plugin.OVSQuantumPluginV2',
    }
  }
  class { 'quantum::plugins::openvswitch':
    openvswitch_settings => $ovs_settings,
  }

  # 
  # Cinder
  #
  $cinder_settings = {
    'DEFAULT' => {
      'rootwrap_config' => '/etc/cinder/rootwrap.conf',
      'sql_connection'  => 'mysql://cinder:password@127.0.0.1/cinder',
      'verbose'         => 'true',
      'rabbit_userid'   => $::admin::params::cloud::rabbit_user,
      'rabbit_password' => $::admin::params::cloud::rabbit_password,
      'rabbit_host'     => 'localhost',
      'log_file'        => '/var/log/cinder/cinder.log',
      'debug'           => 'true',
    }
  }

  class { 'cinder':
    cinder_settings   => $cinder_settings,
    keystone_password => $::admin::params::cloud::cinder_keystone_password,
  }
  class { ['cinder::api', 'cinder::scheduler']: }

  # 
  # Horizon
  #
  $horizon_settings = {
    '' => {
      'QUANTUM_ENABLED' => 'True',
      'SWIFT_ENABLED'   => 'True',
      'SECRET_KEY'      => '12345',
    }
  }
  class { 'horizon': horizon_settings => $horizon_settings }
  class { 'memcached': }

  # Create an openrc auth file
  class { 'openstack::auth_file': 
    admin_password       => $::admin::params::cloud::keystone_admin_password,
    keystone_admin_token => $::admin::params::cloud::keystone_admin_token,
    admin_tenant         => $::admin::params::cloud::keystone_admin_tenant,
  }

  # Nagios checks
  $procs_to_check = [
    'keystone-all', 'glance-api', 'glance-registry',
    'nova-api', 'nova-scheduler', 'nova-objectstore', 'nova-consoleauth', 'nova-cert',
    'quantum-server', 'quantum-agent'
  ]

  class { 'admin::nagios::check_mysql_nrpe': 
    contact_groups => ['sysadmins'],
  }
  admin::nagios::basic_proc_check_nrpe { $procs_to_check:
    contact_groups => ['sysadmins'],
  }
  class { 'admin::nagios::check_http': 
    contact_groups => ['sysadmins'],
  }

}

class admin::cloud::compute { 

  #
  # Nova
  #

  # Nova settings
  $nova_settings = {
    'DEFAULT' => {
      'verbose'                   => 'true',
      'debug'                     => 'true',
      'sql_connection'            => $::admin::params::cloud::nova_db,
      'image_service'             => 'nova.image.glance.GlanceImageService',
      'rabbit_host'               => 'localhost',
      'rabbit_userid'             => $::admin::params::cloud::rabbit_user,
      'rabbit_password'           => $::admin::params::cloud::rabbit_password,
      'metadata_host'             => $::admin::params::cloud::controller_private_ip,
      'routing_source_ip'         => $::admin::params::cloud::controller_private_ip,
      'glance_api_servers'        => "${::admin::params::cloud::controller_private_ip}:9292",
      'volume_api_class'          => 'nova.volume.cinder.API',
      'novnc_enable'              => 'true',
      'novncproxy_base_url'       => "http://${::admin::params::cloud::controller_private_ip}:6080/vnc_auto.html",
      'vncserver_listen'          => $::admin::params::private_ip,
      'vncserver_proxyclient_address' => $::admin::params::private_ip,
      'quantum_use_dhcp'          => 'true',
      'network_api_class'         => 'nova.network.quantumv2.api.API',
      'libvirt_vif_type'          => 'ethernet',
      'quantum_admin_username'    => 'quantum',
      'quantum_admin_password'    => $::admin::params::cloud::quantum_keystone_password,
      'quantum_admin_auth_url'    => "http://${::admin::params::cloud::keystone_host}:35357/v2.0",
      'quantum_auth_strategy'     => 'keystone',
      'quantum_admin_tenant_name' => 'services',
      'quantum_url'               => "http://${::admin::params::cloud::controller_private_ip}:9696",
      'nova_vif_driver'           => 'nova.virt.libvirt.vif.LibvirtHybridOVSBridgeDriver',
      'linuxnet_interface_driver' => 'nova.network.linux_net.LinuxOVSInterfaceDriver',
      'libvirt_use_virtio_for_bridges' => 'true',
      'connection_type'           => 'libvirt',
      'libvirt_type'              => 'kvm',
    }
  }

  # Configure Nova
  class { 'nova':
    nova_settings     => $nova_settings,
    keystone_password => $::admin::params::cloud::nova_admin_password,
  }

  # Nova compute
  class { 'nova::compute': }
  class { 'nova::compute::libvirt': }

  #
  # Quantum
  #

  # Quantum settings
  $quantum_settings = {
    'DEFAULT' => {
      'verbose'          => 'true',
      'debug'            => 'true',
      'control_exchange' => 'quantum',
      'fake_rabbit'      => 'false',
      'rabbit_password'  => $::admin::params::cloud::rabbit_password,
      'rabbit_host'      => 'localhost',
      'rabbit_userid'    => $::admin::params::cloud::rabbit_user,
    }
  }
  $quantum_dhcp_settings = {
    'DEFAULT' => {
      'verbose'       => 'true',
      'debug'         => 'true',
      'db_connection' => $::admin::params::cloud::quantum_db,
    }
  }

  # Configure Quantum
  class { 'quantum':
    quantum_settings      => $quantum_settings,
    quantum_dhcp_settings => $quantum_dhcp_settings,
    keystone_password     => $::admin::params::cloud::quantum_keystone_password,
  }

  # Configure Open vSwitch for Quantum
  $ovs_settings = {
    'DATABASE' => {
      'sql_connection' => $::admin::params::cloud::quantum_db,
    },
    'OVS' => {
      'bridge_mappings' => 'default:br-int',
    }
  }
  class { 'quantum::plugins::openvswitch':
    controller           => false,
    openvswitch_settings => $ovs_settings,
  }
 
  #
  # Cinder
  #

  # Cinder settings
  $cinder_settings = {
    'DEFAULT' => {
      'rootwrap_config' => '/etc/cinder/rootwrap.conf',
      'sql_connection'  => 'mysql://cinder:password@127.0.0.1/cinder',
      'verbose'         => 'true',
      'rabbit_userid'   => $::admin::params::cloud::rabbit_user,
      'rabbit_password' => $::admin::params::cloud::rabbit_password,
      'rabbit_host'     => 'localhost',
      'log_file'        => '/var/log/cinder/cinder.log',
      'debug'           => 'true',
    }
  }
  $iscsi_settings = {
    'DEFAULT' => {
      'volume_group' => 'nova-volumes',
    }
  }

  class { 'cinder':
    cinder_settings   => $cinder_settings,
    keystone_password => $::admin::params::cloud::cinder_keystone_password,
  }

  class { 'cinder::volume': }
  class { 'cinder::volume::iscsi':
    iscsi_settings => $iscsi_settings,
  }

  $procs_to_check = [
    'nova-compute', 'cinder-volume'
  ]

  # Nagios check
  admin::nagios::basic_proc_check_nrpe { $procs_to_check: 
    contact_groups => ['sysadmins'],
  }
  class { 'admin::nagios::check_kvm-pegged_nrpe': 
    contact_groups => ['sysadmins'],
  }
} 
