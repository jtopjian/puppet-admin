class admin::mail::postfix (
  $my_networks = ['127.0.0.0/8', '[::ffff:127.0.0.0]/104', '[::1]/128'],
  $relayhost = undef
) {
  package { 'postfix':
    ensure => latest,
  }

  file { '/etc/postfix/main.cf': 
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('admin/mail/main.cf.erb'),
    notify  => Service['postfix'],
    require => Package['postfix'],
  }

  service { 'postfix':
    ensure  => running,
    enable  => true, 
    require => Package['postfix'],
  }

}
