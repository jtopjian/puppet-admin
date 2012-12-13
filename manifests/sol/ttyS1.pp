class admin::sol::ttyS1 {

  file { '/etc/init/ttyS1.conf':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/admin/sol/ttyS1.conf',
  }

  file { '/etc/init.d/ttyS1':
    ensure => link,
    target => '/lib/init/upstart-job',
  }

  service { 'ttyS1':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

}
