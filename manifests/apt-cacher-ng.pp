class admin::apt-cacher-ng {
  package { 'apt-cacher-ng':
    ensure => latest,
  }

  service { 'apt-cacher-ng':
    enable     => true,
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['apt-cacher-ng'],
  }
}
