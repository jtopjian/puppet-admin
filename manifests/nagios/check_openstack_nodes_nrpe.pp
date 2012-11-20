class admin::nagios::check_openstack_nodes_nrpe (
  $contact_groups,
  $location
) inherits admin::nagios::global_nrpe {
  @@nagios_service { 'check_openstack_nodes':
    service_description => "OpenStack Nodes",
    check_command       => 'check_nrpe_1arg!check_openstack_nodes',
    contact_groups      => $contact_groups,
    tag                 => $location,
  }

  concat::fragment { 'check_openstack_nodes':
    target  => '/etc/nagios/nrpe.cfg',
    content => template('admin/nagios/nrpe/check_openstack_nodes_nrpe.erb'),
    order   => 03,
  }

  file { '/usr/lib/nagios/plugins/check_openstack_nodes.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '755',
    source  => "puppet:///modules/admin/nagios/check_openstack_nodes.sh",
  }

  file { '/etc/sudoers.d/check_openstack_nodes':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    content => "nagios ALL = NOPASSWD: /usr/lib/nagios/plugins/check_openstack_nodes.sh\n",
    require => File['/usr/lib/nagios/plugins/check_openstack_nodes.sh'],
  }
}
