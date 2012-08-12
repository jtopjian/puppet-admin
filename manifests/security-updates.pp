class admin::security-updates {
  if $lsbdistid == "Ubuntu" {
    package { "unattended-upgrades":
      ensure => installed,
    }
    
    file { "/etc/apt/apt.conf.d/20auto-upgrades":
      ensure => present,
      owner => "root",
      group => "root",
      mode => "644",
      source => "puppet:///modules/admin/20auto-upgrades.tpl",
      require => Package['unattended-upgrades'],
    }
  }
}
