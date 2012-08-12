class admin::backups::mysql {

  class { 'admin::backups': }

  File { 
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  file { '/etc/cron.d/backup-mysql':
    ensure  => present,
    content => "5 1 * * * root /usr/local/bin/backup_mysql.sh > /dev/null\n",
  }

  file { '/var/lib/backups/mysql':
    ensure => directory,
  }

  file { '/usr/local/bin/backup_mysql.sh':
    ensure => present,
    mode   => '0700',
    source => "puppet:///modules/admin/backups/backup_mysql.sh",
  }

}
