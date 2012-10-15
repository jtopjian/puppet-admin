include admin::functions

# Configure filebucket backup
filebucket { "main":
    server => $::admin::params::private_hostname,
    path => false,
}

File { backup => main }

import 'nodes.pp'
