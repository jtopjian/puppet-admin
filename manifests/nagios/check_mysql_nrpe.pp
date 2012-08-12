class admin::nagios::check_mysql_nrpe ( 
  $contact_groups
) inherits admin::nagios::global_nrpe {
  @@nagios_service { "check_mysql_${hostname}":
    service_description => 'MySQL',
    check_command       => 'check_nrpe_1arg!check_mysql',
    contact_groups      => $contact_groups,
  }

  concat::fragment { 'check_mysql':
    target  => '/etc/nagios/nrpe.cfg',
    content => template('admin/nagios/nrpe/check_mysql_nrpe.erb'),
    order   => 03,
  }

  file { '/etc/sudoers.d/check_mysql_nrpe':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    content => "nagios ALL = NOPASSWD: /usr/lib/nagios/plugins/check_mysql\n",
  }
}
