class admin::puppet::master (
  $puppet_dashboard_user,
  $puppet_dashboard_password,
  $puppet_dashboard_site,
  $puppet_storeconfigs_password = 'password',
  $hiera    = true,
  $puppetdb = false
) {

  # Add Puppet apt repo
  apt::source { 'puppet':
    location    => 'http://apt.terrarum.net/ubuntu',
    release     => $::lsbdistcodename,
    repos       => 'main',
    key         => 'F8793AF4',
    key_server  => 'subkeys.pgp.net',
    include_src => false,
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
  Apt::Source['puppet'] -> Class['::puppet::master']
  Class['mysql::server'] -> Class['puppet']

  # Configure Puppet + passenger + dashboard
  if $puppetdb {
    Apt::Source['puppet'] -> Class['puppetdb::server']
    class { 'puppet':
      master                 => true,
      agent                  => true,
      agent_cron             => false,
      autosign               => true,
      puppet_passenger       => true,
      storeconfigs           => true,
      storeconfigs_dbadapter => 'puppetdb',
      dashboard              => true,
      dashboard_user         => $puppet_dashboard_user,
      dashboard_password     => $puppet_dashboard_password,
      dashboard_db           => 'puppet_dashboard',
      dashboard_site         => $puppet_dashboard_site,
      dashboard_passenger    => true,
      dashboard_port         => '3000',
      require                => Apt::Source['puppet'],
      before                 => File['/etc/default/puppet-dashboard-workers'],
    }

    class { 'puppetdb':
      database => 'embedded',
      require  => Package['puppetmaster'],
    }
    class { 'puppetdb::master::config':
      require => Class['puppetdb'],
    }
  } else {
    class { 'puppet':
      master                  => true,
      agent                   => true,
      autosign                => true,
      puppet_passenger        => true,
      storeconfigs            => false,
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

  # Configure dashboard pruning
  file { '/usr/share/puppet-dashboard/bin/prune.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/admin/puppet/prune.sh',
    require => Class['puppet'],
  }

  cron { 'puppet dashboard prune':
    command => '/usr/share/puppet-dashboard/bin/prune.sh',
    user    => 'root',
    minute  => '0',
    hour    => '3',
    require => File['/usr/share/puppet-dashboard/bin/prune.sh'],
  }

  if $hiera {
    class { 'admin::puppet::hiera': }
  }

}
