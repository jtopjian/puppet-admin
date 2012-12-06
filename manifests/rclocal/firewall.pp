#
class admin::rclocal::firewall inherits admin::rclocal::base {

  $external_interface = hiera('public_interface')
  $internal_interface = hiera('internal_interface')
  $internal_network   = hiera('private_network')
  $trusted_networks   = hiera('trusted_networks')

  concat::fragment { 'rclocal firewall':
    target  => $::admin::rclocal::base::rclocal_file,
    content => template('admin/rclocal/firewall.erb'),
    order   => 2,
  }
}

