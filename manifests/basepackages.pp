class admin::basepackages {

  $packages = ['git', 'tmux', 'logrotate', 'netcat', 'rsync', 'logwatch']

  package { $packages:
    ensure => latest,
  }

}
