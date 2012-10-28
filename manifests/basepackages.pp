class admin::basepackages {

  $packages = ['git', 'tmux', 'logrotate', 'netcat', 'logwatch']

  package { $packages:
    ensure => latest,
  }

}
