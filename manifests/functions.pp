class admin::functions {
  define enable_ssh_key ($user, $key) {
    ssh_authorized_key { $name:
      ensure => present,
      user   => root,
      type   => 'rsa',
      key    => $key,
    }
  }

  define facter_dotd ($value) {
    file { $name:
      path   => "/etc/facter/facts.d/${name}",
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      content => "${key}=${value}\n",
    }
  }

  define add_host ($ip, $location, $aliases=[]) {
    @@host { $name:
      ensure       => present, 
      ip           => $ip,
      host_aliases => $aliases,
      tag          => $location,
    }
  }

}
