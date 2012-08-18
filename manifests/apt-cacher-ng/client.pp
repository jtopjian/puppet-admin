class admin::apt-cacher-ng::client (
  $server
) {
  file { '/etc/apt/apt.conf.d/01apt-cacher-ng-proxy':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "Acquire::http { Proxy \"http://${server}:3142\"; };",
  }
}
