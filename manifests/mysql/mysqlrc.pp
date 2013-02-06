#
class admin::mysql::mysqlrc (
  $comment = 'no comment'
) {

  # Allow root to access from all trusted networks and hosts
  $mysql_allowed_hosts   = hiera('mysql_allowed_hosts')
  $mysql_helper_user     = hiera('mysql_helper_user')
  $mysql_helper_password = hiera('mysql_helper_password')

  admin::functions::mysql_host_access { $mysql_allowed_hosts: 
    user       => $mysql_helper_user,
    password   => $mysql_helper_password,
    privileges => ['select_priv', 'update_priv', 'insert_priv'],
  }

  # Build a mysql reference file of all dbs
  include concat::setup
  concat { '/root/.mysqlrc':
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
    tag    => 'mysqlrc',
  }

  @@concat::fragment { "/root/.mysqlrc ${::fqdn}":
    target  => '/root/.mysqlrc',
    content => template('admin/mysql/mysqlrc.erb'),
    tag     => 'mysqlrc',
  }

  Concat::Fragment <<| tag == 'mysqlrc' |>>
}
