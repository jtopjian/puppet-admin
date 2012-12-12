#
class admin::openstack::controller::packages {

  $packages = ['ruby-mysql', 'rubygems', 'ruby-json']

  package { $packages:
    ensure => installed,
  }


  $gems = ['terminal-table', 'eventmachine', 'amqp', 'json']
  package { $gems:
    ensure   => installed,
    provider => gem,
  }
}
