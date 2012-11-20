# swift configuration
class admin::openstack::swift::node (
  $swift_zone
) {

  class { 'admin::openstack::swift::base': }

  swift::storage::xfs { ['sda6', 'sdb6', 'sdc', 'sdd', 'sde', 'sdf']: }

  # install all swift storage servers together
  class { '::swift::storage::all':
    storage_local_net_ip => hiera('private_ip'),
  }

  $ip = hiera('private_ip')
  # specify endpoints per device to be added to the ring specification
  @@ring_object_device {
    ["${ip}:6000/sda6",
     "${ip}:6000/sdb6",
     "${ip}:6000/sdc",
     "${ip}:6000/sdd",
     "${ip}:6000/sde",
     "${ip}:6000/sdf"]:
       zone   => $swift_zone,
       weight => 1,
       tag    => $::location,
  }

  @@ring_container_device {
    ["${ip}:6001/sda6",
     "${ip}:6001/sdb6",
     "${ip}:6001/sdc",
     "${ip}:6001/sdd",
     "${ip}:6001/sde",
     "${ip}:6001/sdf"]:
       zone   => $swift_zone,
       weight => 1,
       tag    => $::location,
  }

  @@ring_account_device {
    ["${ip}:6002/sda6",
     "${ip}:6002/sdb6",
     "${ip}:6002/sdc",
     "${ip}:6002/sdd",
     "${ip}:6002/sde",
     "${ip}:6002/sdf"]:
       zone   => $swift_zone,
       weight => 1,
       tag    => $::location,
  }

  # collect resources for synchronizing the ring databases
  Swift::Ringsync<<| tag == $::location |>>
}

