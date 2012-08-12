class admin::hosts (
  $ip_address
) {
  @@host { $fqdn:
    ensure       => present,
    ip           => $ip_address,
    host_aliases => [$hostname],
  }

  Host <<||>>

}
