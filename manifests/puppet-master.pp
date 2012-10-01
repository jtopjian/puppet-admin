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
  Apt::Source['puppet'] -> Class['puppetdb::server']
  Apt::Source['puppet'] -> Class['puppet::master']

  # Configure Puppet + passenger + dashboard
  class { 'puppet':
    master                  => true,
    agent                   => true,
    autosign                => true,
    puppet_passenger        => true,
    storeconfigs            => true,
    storeconfigs_dbadapter  => 'puppetdb',
    #storeconfigs_dbuser     => 'puppet',
    #storeconfigs_dbpassword => $puppet_storeconfigs_password,
    #storeconfigs_dbserver   => 'localhost',
    dashboard               => true,
    dashboard_user          => $puppet_dashboard_user,
    dashboard_password      => $puppet_dashboard_password,
    dashboard_db            => 'puppet_dashboard',
    dashboard_site          => $puppet_dashboard_site,
    dashboard_passenger     => true,
    dashboard_port          => '3000',
    require                 => Apt::Source['puppet'],
    before                  => File['/etc/default/puppet-dashboard-workers'],
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
    require => Package['puppet-dashboard'],
  }

  service { 'puppet-dashboard-workers':
    ensure     => running,
    enable     => true,
    require    => Package['puppet-dashboard'],
  }

  class { 'puppetdb':
    database => 'embedded',
    before   => Package['puppetmaster'],
  }
  class { 'puppetdb::master::config':
    require => Class['puppetdb'],
    before  => Package['puppetmaster'],
  }

}
