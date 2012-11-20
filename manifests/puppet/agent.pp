class admin::puppet::agent (
  $puppet_server,
  $version = 'present',
) {

  # Add Puppet apt repo
  apt::source { 'puppet':
    location    => 'http://apt.terrarum.net/ubuntu',
    release     => $::lsbdistcodename,
    repos       => 'main',
    key         => 'F8793AF4',
    key_server  => 'subkeys.pgp.net',
    include_src => false,
    notify      => Exec['jt apt-get update'],
  }

  exec { 'jt apt-get update':
    path        => ['/bin', '/usr/bin'],
    command     => 'apt-get update',
    refreshonly => true,
  }

  class { '::puppet':
    puppet_server => $puppet_server,
    version       => $version,
    agent_cron    => false,
    require       => Apt::Source['puppet'],
  }

}
