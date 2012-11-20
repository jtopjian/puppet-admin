class admin::rclocal::base {
  include concat::setup

  $rclocal_file = '/etc/rc.local'

  concat { $rclocal_file:
    owner => 'root',
    group => 'root',
    mode  => '0755',
  }

  concat::fragment { 'rclocal header':
    target  => $rclocal_file,
    content => template('admin/rclocal/header.erb'),
    order   => 1,
  }

  concat::fragment { 'rclocal exit':
    target  => $rclocal_file,
    content => "# Standard exit\nexit 0\n",
    order   => 99,
  }
}
