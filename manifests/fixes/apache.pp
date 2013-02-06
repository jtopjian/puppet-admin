class admin::fixes::apache {

  file_line { '/etc/apache2/ports.conf NameVirtualHost':
    path    => '/etc/apache2/ports.conf',
    line    => '#NameVirtualHost *:80',
    match   => 'NameVirtualHost.*:80',
    require => Package['apache2'],
  }


}
