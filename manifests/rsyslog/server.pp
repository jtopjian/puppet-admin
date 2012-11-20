#
class admin::rsyslog::server (
  $interface = '0.0.0.0'
) {

    class { 'admin::rsyslog::base': }

    file { "/etc/rsyslog.d/server.conf":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('admin/rsyslog/server.conf.erb'),
        notify  => Service['rsyslog'],
    }

    file { '/etc/logrotate.d/cloud-rsyslog':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => 'puppet:///modules/admin/rsyslog/cloud-rsyslog.logrotate',
    }

    file { '/var/log/rsyslog':
        ensure  => directory,
        owner   => 'syslog',
        group   => 'syslog',
        mode    => "0750",
    }

}
