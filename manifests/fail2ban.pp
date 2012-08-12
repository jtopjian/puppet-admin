class admin::fail2ban (
  $ignore_networks = '127.0.0.1'
) {
  package { 'fail2ban':
    ensure => latest,
  }

  file { '/etc/fail2ban/jail.conf':
    ensure   => present,
    content  => template('admin/fail2ban/jail.conf.erb'),
    require  => Package['fail2ban'],
    notify   => Service['fail2ban'],
  }

  service { 'fail2ban':
    enable     => true,
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    require    => File['/etc/fail2ban/jail.conf'],
  }
}
