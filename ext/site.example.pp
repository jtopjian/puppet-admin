include admin::functions

# Configure filebucket backup
filebucket { "main":
    server => hiera('puppet_server'),
    path => false,
}

File { backup => main }

import 'nodes.pp'
