#
class admin::mcollective::rabbitmq (
  $username,
  $password
) {


  # This assumes rabbitmq is running on a cloud controller

 file { '/usr/sbin/rabbitmq-env':
    ensure => link,
    target => '/usr/lib/rabbitmq/bin/rabbitmq-env',
  }

  file { '/usr/sbin/rabbitmq-plugins':
    ensure  => link,
    target  => '/usr/lib/rabbitmq/bin/rabbitmq-plugins',
    require => File['/usr/sbin/rabbitmq-env'],
  }

  rabbitmq_user { $username:
    admin    => true,
    password => $password,
    provider => 'rabbitmqctl',
  }
 
  rabbitmq_user_permissions { "${username}@/":
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
    provider             => 'rabbitmqctl',
  }

  rabbitmq_plugin {'rabbitmq_stomp':
    ensure   => present,
    provider => 'rabbitmqplugins',
    require  => File['/usr/sbin/rabbitmq-plugins'],
  }

  rabbitmq_plugin {'amqp_client':
    ensure   => present,
    provider => 'rabbitmqplugins',
    require  => File['/usr/sbin/rabbitmq-plugins'],
  }
}
