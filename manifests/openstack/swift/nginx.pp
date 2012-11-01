class admin::openstack::swift::nginx (
  $location,
  $listen,
  $upstream
) {

  package { 'nginx':
    ensure => present,
  }

  File {
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    ensure  => present,
    require => Package['nginx'],
    notify  => Service['nginx'],
  }

  file { '/etc/nginx/sites-available/default':
    content => template('admin/openstack/swift/nginx/default.erb'),
  }

  file { '/etc/nginx/nginx.conf':
    source => 'puppet:///admin/openstack/swift/nginx/nginx.conf',
  }

  file { '/etc/nginx/server.crt':
    source => "puppet:///admin/openstack/swift/nginx/${location}.crt",
  }

  file { '/etc/nginx/server.key':
    source => "puppet:///admin/openstack/swift/nginx/${location}.key",
  }

  service { 'nginx':
    ensure  => running,
    enable  => true,
    require => Package['nginx'],
  }

}
