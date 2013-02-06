class admin::basepackages {

  $packages = ['git', 'tmux', 'logrotate', 'netcat', 'logwatch', 'cpufrequtils', 'vim', 'nfs-common', 'ipmitool', 'bsd-mailx', 'dsh', 'ubuntu-cloud-keyring', 'lldpd', 'htop', 'smartmontools']

  package { $packages:
    ensure => latest,
  }

}
