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

  # Configure /etc/cobbler/modules.conf
  admin::functions::replace { '/etc/cobbler/modules.conf dns': 
    file        => '/etc/cobbler/modules.conf',
    pattern     => 'module = manage_bind',
    replacement => 'module = manage_dnsmasq',
  }
  admin::functions::replace { '/etc/cobbler/modules.conf dhcp':
    file        => '/etc/cobbler/modules.conf',
    pattern     => 'module = manage_isc',
    replacement => 'module = manage_dnsmasq',
  }

  # Configure /etc/cobbler/dnsmasq.template
  admin::functions::ensure_key_value { '/etc/cobbler/dnsmasq.template server':
    file      => '/etc/cobbler/dnsmasq.template',
    key       => 'server',
    value     => $dns_upstream_server,
    delimiter => '='
  }

  admin::functions::ensure_key_value { '/etc/cobbler/dnsmasq.template dhcp-range':
    file      => '/etc/cobbler/dnsmasq.template',
    key       => 'dhcp-range',
    value     => "${dhcp_start_range},${dhcp_stop_range}",
    delimiter => '='
  }

  # Configure /etc/cobbler/settings
  admin::functions::ensure_key_value { '/etc/cobbler/settings puppet_auto_setup':
    file      => '/etc/cobbler/settings',
    key       => 'puppet_auto_setup',
    value     => '1',
    delimiter => ': ',
  }

  admin::functions::ensure_key_value { '/etc/cobbler/settings manage_dhcp':
    file      => '/etc/cobbler/settings',
    key       => 'manage_dhcp',
    value     => '1',
    delimiter => ': ',
  }

  admin::functions::ensure_key_value { '/etc/cobbler/settings manage_dns':
    file      => '/etc/cobbler/settings',
    key       => 'manage_dns',
    value     => '1',
    delimiter => ': ',
  }

  admin::functions::ensure_key_value { '/etc/cobbler/settings next_server':
    file      => '/etc/cobbler/settings',
    key       => 'next_server',
    value     => $next_server,
    delimiter => ': ',
  }

  admin::functions::ensure_key_value { '/etc/cobbler/settings server':
    file      => '/etc/cobbler/settings',
    key       => 'server',
    value     => $server,
    delimiter => ': ',
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
