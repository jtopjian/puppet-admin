#
class admin::mcollective::plugins {

  class { '::mcollective::plugins': }

  mcollective::plugins::plugin { 'ping':
    type => 'application',
  }

  mcollective::plugins::plugin { 'puppetd':
    type        => 'agent',
    ddl         => true,
    application => true,
  }

  mcollective::plugins::plugin { 'puppetral':
    type => 'agent',
    ddl  => true,
  }

  mcollective::plugins::plugin { 'controller':
    type => 'application',
  }

  mcollective::plugins::plugin { 'dsh':
    type => 'application',
  }

}

