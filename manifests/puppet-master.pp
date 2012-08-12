class admin::puppet-master (
  $puppet_dashboard_user,
  $puppet_dashboard_password,
  $puppet_dashboard_site,
  $puppet_storeconfigs_password
) {

  # Add Puppet apt repo
  apt::source { 'puppet':
    location   => 'http://apt.puppetlabs.com',
    release    => $::lsbdistcodename,
    repos      => 'main',
    key        => '4BD6EC30',
    key_server => 'subkeys.pgp.net',
  }

  # Setup activerecord
  package { 'activerecord':
    provider => gem,
    ensure   => '3.0.11',
  }

  package { 'libmysql-ruby':
    ensure => present,
  }

  # Make sure the apt repo is added before puppet is configured
  Apt::Source['puppet'] -> Class['puppet']

  # Configure Puppet + passenger + dashboard
  class { 'puppet':
    master                  => true,
    agent                   => false,
    autosign                => true,
    puppet_passenger        => true,
    storeconfigs            => true,
    storeconfigs_dbadapter  => 'mysql',
    storeconfigs_dbuser     => 'puppet',
    storeconfigs_dbpassword => $puppet_storeconfigs_password,
    storeconfigs_dbserver   => 'localhost',
    dashboard               => true,
    dashboard_user          => $puppet_dashboard_user,
    dashboard_password      => $puppet_dashboard_password,
    dashboard_db            => 'puppet_dashboard',
    dashboard_site          => $puppet_dashboard_site,
    dashboard_passenger     => true,
    dashboard_port          => '8080',
  }

  class { 'dashboard::db::mysql': 
    db_name     => 'puppet_dashboard',
    db_user     => $puppet_dashboard_user,
    db_password => $puppet_dashboard_password,
  }

  # Configure dashboard workers
  file { '/etc/default/puppet-dashboard-workers':
    ensure  => present,
    content => template('admin/puppet/puppet-dashboard-workers.default.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Class['dashboard'],
  }

  service { 'puppet-dashboard-workers':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }

}
