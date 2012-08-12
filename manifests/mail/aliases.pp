class admin::mail::aliases {
  Mailalias { notify => Exec['newaliases'] }

  exec { 'newaliases': 
    command     => '/usr/bin/newaliases',
    refreshonly => true,
  }

  # Put aliases here
  mailalias { 'root':
    recipient => ['joe.topjian@cybera.ca'],
  }

}
