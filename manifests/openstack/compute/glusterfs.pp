class admin::openstack::compute::glusterfs {

  # GlusterFS PPA
  class { 'apt': }
  apt::ppa { 'ppa:semiosis/ubuntu-glusterfs-3.3': }

  # GlusterFS
  package { ['glusterfs-server', 'glusterfs-client']:
    ensure  => installed,
    require => Apt::Ppa['ppa:semiosis/ubuntu-glusterfs-3.3'],
  }
}
