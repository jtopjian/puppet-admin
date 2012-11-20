# swift configuration
class admin::openstack::swift::base {
  class { '::swift':
    swift_hash_suffix => hiera('swift_hash_suffix'),
  }
  class { 'ssh': }
}
