class admin::openstack::quotas {
  file { '/etc/init.d/nova-quotas':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/admin/openstack/nova-quotas',
  }

  service { 'nova-quotas':
    ensure     => running,
    enable     => true,
    hasstatus  => false,
    hasrestart => false,
    status     => 'ps aux | grep quota-daemon | grep -v grep',
    require    => File['/etc/init.d/nova-quotas'],
  }

  cron { 'nova-quotas balance':
    command     => 'novac quota-balance',
    environment => 'PATH=/bin:/usr/bin:/sbin:/usr/sbin:/root/novac/bin',
    user        => 'root',
    minute      => '0',
    require     => Vcsrepo['/root/novac'],
  }

  cron { 'nova-quotas sync limits':
    command     => 'novac quota-sync-limits',
    environment => 'PATH=/bin:/usr/bin:/sbin:/usr/sbin:/root/novac/bin',
    user        => 'root',
    minute      => '*/15',
    require     => Vcsrepo['/root/novac'],
  }
}
