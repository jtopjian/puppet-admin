class admin::libvirtd_uuid {
  file_line { 'libvirtd host_uuid':
    path    => '/etc/libvirt/libvirtd.conf',
    line    => "host_uuid = \"${::fqdn_uuid}\"",
    match   => "host_uuid =",
    require => Package['libvirt-bin'],
    notify  => Service['libvirt-bin'],
  }
}
