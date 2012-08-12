class admin::rsyslog {
    package { "rsyslog":
        ensure => installed,
    }

    service { "rsyslog":
        ensure => running,
        hasrestart => true,
        enable => true,
        require => Package['rsyslog'],
    }

}
