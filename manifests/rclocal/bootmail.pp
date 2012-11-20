#
class admin::rclocal::bootmail inherits admin::rclocal::base {

  $mail = 'echo "`hostname` booted on `date`" | mail -s "`hostname` booted" root'

  concat::fragment { 'rclocal bootmail':
    target  => $::admin::rclocal::base::rclocal_file,
    content => "# Send an email whenever the server boots\n${mail}\n\n",
    order   => 98,
  }
}
