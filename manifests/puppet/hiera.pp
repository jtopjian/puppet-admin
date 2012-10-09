# Class: puppet::hiera
#
# This class installs and configures hiera for Puppet master
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class admin::puppet::hiera (
  $confdir    = '/etc/puppet',
  $modulepath = '/etc/puppet/modules',
  $provider   = 'gem'
) {

  package { 'hiera':
    ensure   => present,
    provider => $provider,
  }

  package { 'hiera-puppet':
    ensure   => present,
    provider => $provider,
  }

  file { "${confdir}/hiera.yaml":
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0644',
    source  => 'puppet:///modules/admin/puppet/hiera.yaml',
    replace => false,
  }

  exec { 'hiera-puppet':
    command => 'git clone git://github.com/puppetlabs/hiera-puppet',
    cwd     => $modulepath,
    path    => '/usr/local/bin:/usr/bin:/bin',
    creates => "${modulepath}/hiera-puppet",
  }

}
