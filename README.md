puppet-admin
============

Bootstrapping Your Admin/Util/PMaster Server
--------------------------------------------

This will set up a full-stack which includes:

  * MySQL
  * Puppet / Puppet Master
  * Puppet Dashboard
  * Cobbler
  * Postfix

```shell
apt-get install -y git rake vim puppet
cd /etc/puppet/modules
git clone https://github.com/jtopjian/puppet-admin admin
cd admin/ext
bash util-bootstrap.sh
cd ../tests
vi bootstrap.pp
# Edit bootstrap.pp to suit your environment
puppet apply --verbose bootstrap.pp
```

Post-Bootstrap Configuration
----------------------------

Once the server has been bootstrapped, you can now apply roles that require Puppet storedconfigs.

The stack will now include:

  * Nagios
  * rsyslog
  * Various mail aliases
  * Ubuntu security update configuration
  * Fail2Ban

```shell
cd /etc/puppet/manifests
cp /etc/puppet/modules/admin/ext/site.example.pp site.pp
cp /etc/puppet/modules/admin/ext/nodes.example.pp nodes.pp
# Edit nodes.pp to suit your environment
# By default, it gives examples of an OpenStack cloud
vi /etc/puppet/modules/admin/manifests/params.pp
# Edit params.pp to suit your environment
```

Bootstrapping Only a Puppet Master Server
-----------------------------------------

If you do not want the full stack, simply run `puppet-master.pp` instead of `bootstrap.pp`.

Files that Contain Site-Specific Data
-------------------------------------

Make sure you edit the following files to suit your environment:

  * cd /etc/puppet/modules/admin/manifests
  * params.pp
  * nagios/contacts.pp
  * mail/aliases.pp
