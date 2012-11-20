# swift configuration
class admin::openstack::swift::proxy {

  class { 'admin::openstack::swift::base': }

  class { 'memcached':
    listen_ip => '127.0.0.1',
  }

  class { '::swift::proxy':
    account_autocreate => true,
    proxy_local_net_ip => hiera('public_ip'),
    pipeline           => ['healthcheck', 'cache', 'swift3', 's3token', 'authtoken', 'keystone', 'proxy-logging', 'proxy-server'],
    log_level          => 'DEBUG',
    require            => Class['swift::ringbuilder'],
  }

  class { '::swift::proxy::keystone':
    operator_roles => ['admin', 'Member', 'swiftoperator'],
  }

  class { '::swift::proxy::authtoken':
    auth_host      => hiera('keystone_public_hostname'),
    admin_password => hiera('swift_keystone_password'),
  }

  class { '::swift::proxy::healthcheck': }
  class { '::swift::proxy::cache': }
  class { '::swift::proxy::swift3': }
  class { '::swift::proxy::proxy-logging': }
  class { '::swift::proxy::s3token':
    auth_host => hiera('keystone_public_hostname'),
  }

  # collect all of the resources that are needed
  # to balance the ring
  Ring_object_device <<| tag == $::location |>>
  Ring_container_device <<| tag == $::location |>>
  Ring_account_device <<| tag == $::location |>>

  # create the ring
  class { '::swift::ringbuilder':
    # the part power should be determined by assuming 100 partitions per drive
    part_power     => '18',
    replicas       => '3',
    min_part_hours => 1,
    require        => Class['swift'],
  }

  # sets up an rsync db that can be used to sync the ring DB
  class { '::swift::ringserver':
    local_net_ip => hiera('private_ip'),
  }

  # exports rsync gets that can be used to sync the ring files
  @@swift::ringsync { ['account', 'object', 'container']:
   ring_server => hiera('private_ip'),
   tag         => $::location,
 }

  # deploy a script that can be used for testing
  file { '/tmp/swift_keystone_test.rb':
    source => 'puppet:///modules/swift/swift_keystone_test.rb'
  }

  # ssl reverse proxy
  #class { 'admin::openstack::swift::nginx':
  #  location => $::location,
  #  listen   => hiera('public_ip'),
  #  upstream => hiera('private_ip'),
  #}


}
