#
class admin::rsyslog::client (
  $rsyslog_server
) {

  include admin::rsyslog::base

  file { "/etc/rsyslog.d/client-common.conf":
    ensure  => present,
    owner   => "root",
    group   => "root",
    mode    => "0644",
    content => template('admin/rsyslog/client-common.conf.erb'),
    require => Package['rsyslog'],
    notify  => Service['rsyslog'],
  }
}
