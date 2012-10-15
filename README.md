puppet-admin
============

Bootstrapping Your Admin/Util/PMaster Server
--------------------------------------------

This will set up:

  * MySQL
  * Puppet / Puppet Master
  * Puppet Dashboard
  * PuppetDB

```shell
# Ensure hostname is correct
vi /etc/hosts

# Ensure you're up to date
apt-get update && apt-get dist-upgrade

# Generate a key
ssh-keygen

# Install base packages
apt-get install -y git rake vim puppet

# Clone the admin repo
cd /etc/puppet/modules
git clone -b dair https://github.com/jtopjian/puppet-admin admin

# Initial bootstrapping
cd admin/ext
bash util-bootstrap.sh

# Configure your environment
cd ../manifests/data
# Edit manifests to suit your environment

# More boostrapping
cd ../tests
# Set your passwords
vi passwords.pp
puppet apply --verbose puppet-master.pp
# If you get errors, try running 2 or 3 times, it's probably just timing / execution order issues

puppet apply --verbose puppet-master-db.pp
# Installing puppet-master and puppetdb at the same time is a chicken-egg scenario. So I chose to just install puppetdb separately.
#
# Again, run 2 or 3 times if you get errors. You will definitely see an error with PuppetDB as it takes longer than 20 seconds to initialize and Puppet only waits 20 seconds for it to start. Just re-run.
```

Post-Bootstrap Configuration
----------------------------

Once the server has been bootstrapped, you can now apply roles that require Puppet storedconfigs.

The stack will now include:

  * Cobbler
  * Nagios
  * rsyslog
  * Various mail aliases
  * Ubuntu security update configuration
  * Fail2Ban

```shell
# Housecleaning
chown -R puppet: /var/lib/puppet/reports/
gem uninstall rack
# Remove 1.4.1

# Configure Hiera
cd /etc/puppet/modules/admin/manifests/data

# `common.pp` contains global values for EVERYTHING
# For $ssh_util_admin_key:
# The key is what you will find in the `id_rsa.pub` file. Strip off the ssh-rsa at the beginning and the name at the end -- meaning, only add the actual key itself, not the entire key entry.

# `dc1.pp` and `dc2.pp` contain global variables for all nodes in that location. Edit it with the proper environment values.

# The `.pp` files that have the names of hostnames are values for that particular hostname. Edit as needed. Make sure to use _ instead of . in the hostnames!

cd /etc/puppet/manifests
cp /etc/puppet/modules/admin/ext/site.example.pp site.pp
cp /etc/puppet/modules/admin/ext/nodes.example.pp nodes.pp
# Edit nodes.pp to suit your environment
# By default, it gives examples of an OpenStack cloud
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
