#
class admin::mcollective::client (
  $server,
  $username,
  $password,
  $psk
) {

  $stomp_pool = { host1 => $server, port1 => '6163', user1 => $username, password1 => $password }
  $pool = { pool1 => $stomp_pool }

  class { 'mcollective':
    stomp_pool      => $pool,
    client          => true,
    server          => true,
    mc_security_psk => $psk,
    version         => 'latest',
  }

}
