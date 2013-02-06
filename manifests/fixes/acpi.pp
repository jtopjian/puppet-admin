class admin::fixes::acpi {
  file { '/etc/acpi/powerbtn.sh':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/admin/fixes/powerbtn.sh',
    notify => Service['acpid'],
  }

  service { 'acpid':
    ensure => running,
    enable => true,
  }
}

