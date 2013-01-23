class admin::openstack::novac {
  vcsrepo { '/root/novac':
    ensure   => present,
    provider => git,
    source   => 'http://github.com/cybera/novac',
    revision => 'dev',
  }

  file { '/etc/sudoers.d/novac':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
    source => 'puppet:///modules/admin/openstack/novac-sudo'
  }
}
