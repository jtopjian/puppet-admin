#
class admin::rabbitmq::rabbitmqrc {

  # Get RabbitMQ auth info
  $rabbitmq_user = hiera('rabbit_user')
  $rabbitmq_pass = hiera('rabbit_password')

  # Build a rabbitmqrc file for all rabbitmq installations
  include concat::setup
  concat { '/root/.rabbitmqrc':
    owner => 'root',
    group => 'root',
    mode  => '0600',
    tag   => 'rabbitmqrc',
  }

  @@concat::fragment { "/root/.rabbitmqrc ${::fqdn}":
    target  => '/root/.rabbitmqrc',
    content => template('admin/rabbitmq/rabbitmqrc.erb'),
    tag     => 'rabbitmqrc',
  }

  Concat::Fragment <<| tag == 'rabbitmqrc' |>>
}
