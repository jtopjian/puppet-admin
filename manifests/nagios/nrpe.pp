class admin::nagios::nrpe (
  $nagiosuser    = 'nagios',
  $nagiosgroup   = 'nagios',
  $allowed_hosts = ['127.0.0.1']
) {
  # nrpe Packages
  $packages = ['nagios-nrpe-server']
  package { $packages: ensure => latest }

  # nrpe config file
  # Using concat so further nrpe checks can be added when needed

  include 'concat::setup'
  $nrpe = '/etc/nagios/nrpe.cfg'
  concat { $nrpe:
    owner => 'root',
    group => 'root',
    mode  => '0644',
    require => Package['nagios-nrpe-server'],
    notify  => Service['nagios-nrpe-server'],
  }

  concat::fragment { 'nrpe_header':
    target  => $nrpe,
    content => template('admin/nagios/nrpe/nrpe_header.erb'),
    order   => 01,
  }

  # nrpe Service
  service { "nagios-nrpe-server":
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['nagios-nrpe-server'],
  }

}
