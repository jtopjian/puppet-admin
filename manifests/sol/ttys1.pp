class admin::sol::ttys1 {

  file { '/etc/init/ttyS1.conf':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/admin/sol/ttyS1.conf',
  }

  file { '/etc/init.d/ttyS1':
    ensure  => link,
    target  => '/lib/init/upstart-job',
    require => File['/etc/init/ttyS1.conf'],
  }

  service { 'ttyS1':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => File['/etc/init.d/ttyS1'],
  }

}
