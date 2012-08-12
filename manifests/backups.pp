class admin::backups {

  file { '/var/lib/backups':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

}
