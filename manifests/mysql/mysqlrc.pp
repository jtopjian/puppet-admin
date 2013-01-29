#
class admin::mysql::mysqlrc (
  $comment = 'no comment'
) {

  $mysql_allowed_hosts   = hiera('mysql_allowed_hosts')
  $mysql_helper_user     = hiera('mysql_helper_user')
  $mysql_helper_password = hiera('mysql_helper_password')

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
