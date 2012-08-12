class admin::nagios::server (
  $admin_password,
) {

  # Nagios Package
  $nagios_packages = ['nagios3', 'nagios-nrpe-plugin']
  package { $nagios_packages: 
    ensure  => latest,
    require => File ['/etc/nagios3'],
  }

  # Nagios Service
  service { 'nagios3':
    enable     => true,
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['nagios3'],
  }

  file { '/etc/nagios3':
    ensure => directory,
  }

  # htpasswd config
  $htpasswd = '/etc/nagios3/.htpasswd'
  file { $htpasswd:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/etc/nagios3'],
  }

  httpauth { 'nagiosadmin':
    file        => $htpasswd,
    password    => $admin_password,
    mechanism   => basic,
    require     => File[$htpasswd],
  }

  # Nagios configuration
  $nagios_config_files = ['/etc/nagios3/conf.d/nagios_hosts.cfg', '/etc/nagios3/conf.d/nagios_services.cfg',
                          '/etc/nagios3/conf.d/nagios_contacts.cfg', '/etc/nagios3/conf.d/nagios_contactgroups.cfg']
  file { $nagios_config_files:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['nagios3'],
    require => Package['nagios3'],
  }

  admin::functions::ensure_key_value { '/etc/nagios3/apache2.conf AuthUserFile':
    file      => '/etc/nagios3/apache2.conf',
    key       => 'AuthUserFile',
    value     => $htpasswd,
    delimiter => ' ',
  }

  Nagios_host {
    notify         => Service['nagios3'],
    target         => '/etc/nagios3/conf.d/nagios_hosts.cfg',
    require        => File['/etc/nagios3/conf.d/nagios_hosts.cfg'],
  }

  Nagios_service {
    notify              => Service['nagios3'],
    target              => '/etc/nagios3/conf.d/nagios_services.cfg',
    require             => File['/etc/nagios3/conf.d/nagios_services.cfg'],
  }

  # Nagios contacts
  class { 'admin::nagios::contacts': }

  # Collect all exported Nagios configs
  Nagios_host    <<||>> 
  Nagios_service <<||>> 

}
