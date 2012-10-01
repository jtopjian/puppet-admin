class admin::cobbler (
  $dns_upstream_server = '8.8.8.8',
  $dhcp_start_range,
  $dhcp_stop_range,
  $next_server,
  $server
) {

  # Packages
  $packages = ['cobbler', 'cobbler-web', 'debmirror', 'dnsmasq']
  package { $packages:
    ensure => latest,
  }

  # Default File options
  File { 
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['cobbler'],
    require => Package['cobbler'],
  }

  Ini_setting {
    require => Package['cobbler'],
  }

  File_line {
    require => Package['cobbler'],
  }

  # Configure /etc/cobbler/modules.conf
  ini_setting { '/etc/cobbler/modules.conf dns':
    path    => '/etc/cobbler/modules.conf',
    section => 'dns',
    setting => 'module',
    value   => 'manage_dnsmasq',
  }

  ini_setting { '/etc/cobbler/modules.conf dhcp':
    path    => '/etc/cobbler/modules.conf',
    section => 'dhcp',
    setting => 'module',
    value   => 'manage_dnsmasq',
  }

  # Configure /etc/cobbler/dnsmasq.template
  ini_setting { '/etc/cobbler/dnsmasq.template server':
    path    => '/etc/cobbler/dnsmasq.template',
    section => '',
    setting => 'server',
    value   => $dns_upstream_server,
  }

  ini_setting { '/etc/cobbler/dnsmasq.template dhcp-range':
    path    => '/etc/cobbler/dnsmasq.template',
    section => '',
    setting => 'dhcp-range',
    value   => "${dhcp_start_range},${dhcp_stop_range}",
  }

  # Configure /etc/cobbler/settings
  file_line { '/etc/cobbler/settings puppet_auto_setup':
    path  => '/etc/cobbler/settings',
    line  => 'puppet_auto_setup: 1',
    match => 'puppet_auto_setup: ',
  }

  file_line { '/etc/cobbler/settings manage_dhcp':
    path  => '/etc/cobbler/settings',
    line  => 'manage_dhcp: 1',
    match => 'manage_dhcp: ',
  }

  file_line { '/etc/cobbler/settings manage_dns':
    path  => '/etc/cobbler/settings',
    line  => 'manage_dns: 1',
    match => 'manage_dns: ',
  }

  file_line { '/etc/cobbler/settings next_server':
    path  => '/etc/cobbler/settings',
    line  => "next_server: ${next_server}",
    match => 'next_server: ',
  }

  file_line { '/etc/cobbler/settings server':
    path  => '/etc/cobbler/settings',
    line  => "server: ${server}",
    match => '^server: ',
  }

  # Get loaders
  exec { 'cobbler-get-loaders':
    command => 'cobbler get-loaders',
    unless  => 'file /var/lib/cobbler/loaders/README',
    path    => ['/bin', '/usr/bin'],
  }

  # Cobbler service
  service { 'cobbler':
    enable     => true,
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['cobbler'],
  }

}
