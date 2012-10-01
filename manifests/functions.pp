class admin::functions {
  define enable_ssh_key ($user, $key) {
    ssh_authorized_key { $name:
      ensure => present,
      user   => root,
      type   => 'rsa',
      key    => $key,
    }
  }
}
