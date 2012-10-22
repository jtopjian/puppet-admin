class admin::puppet::agent (
  $puppet_server,
  $version = 'present',
) {

  # Add Puppet apt repo
  apt::source { 'puppet':
    location    => 'http://panel.terrarum.net/puppet',
    release     => $::lsbdistcodename,
    repos       => 'main',
    key         => 'F8793AF4',
    key_server  => 'subkeys.pgp.net',
    include_src => false,
  }

  class { '::puppet':
    puppet_server => $puppet_server,
    version       => $version,
    require       => Apt::Source['puppet'],
  }

}
