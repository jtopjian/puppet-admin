# cloud configuration
class admin::openstack::controller::mysql {
  ## MySQL
  # Install and configure MySQL Server
  class { 'mysql::server':
    config_hash => {
      'root_password' => hiera('mysql_root_password'),
      'bind_address'  => hiera('mysql_bind_address'),
    },
    enabled     => $enabled,
  }

  # This removes default users and guest access
  class { 'mysql::server::account_security': }

  # Configure mysql backups
  class { 'admin::backups::mysql': }

  # Create the Keystone db
  class { 'keystone::db::mysql':
    user          => hiera('keystone_mysql_user'),
    password      => hiera('keystone_mysql_password'),
    dbname        => hiera('keystone_mysql_dbname'),
    allowed_hosts => hiera('mysql_allowed_hosts'),
  }

  # Create the Glance db
  class { 'glance::db::mysql':
    user          => hiera('glance_mysql_user'),
    password      => hiera('glance_mysql_password'),
    dbname        => hiera('glance_mysql_dbname'),
    allowed_hosts => hiera('mysql_allowed_hosts'),
  }

  # Create the Nova db
  class { 'nova::db::mysql':
    user          => hiera('nova_mysql_user'),
    password      => hiera('nova_mysql_password'),
    dbname        => hiera('nova_mysql_dbname'),
    allowed_hosts => hiera('mysql_allowed_hosts'),
  }

  # Create the Cinder db
  class { 'cinder::db::mysql':
    user          => hiera('cinder_mysql_user'),
    password      => hiera('cinder_mysql_password'),
    dbname        => hiera('cinder_mysql_dbname'),
    allowed_hosts => hiera('mysql_allowed_hosts'),
  }

  # Create a helper user so scripts don't have to use root
  $mysql_allowed_hosts   = hiera('mysql_allowed_hosts')
  $mysql_helper_user     = hiera('mysql_helper_user')
  $mysql_helper_password = hiera('mysql_helper_password')

  admin::functions::mysql_host_access { $mysql_allowed_hosts:
    user       => $mysql_helper_user,
    password   => $mysql_helper_password,
    privileges => ['select_priv', 'update_priv', 'insert_priv'],
  }

}
