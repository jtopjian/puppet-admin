class admin::openstack::novac {
  vcsrepo { '/root/novac':
    ensure   => present,
    provider => git,
    source   => 'http://github.com/cybera/novac',
    revision => 'dev',
  }
}
