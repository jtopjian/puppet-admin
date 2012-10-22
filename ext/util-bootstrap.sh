#!/bin/bash

cd /root

# Install basic packages
apt-get update
apt-get install -y puppet git rubygems rake

# Install required puppet modules
cd /etc/puppet/modules
git clone -b jtopjian-mods https://github.com/jtopjian/puppetlabs-puppet puppet
git clone -b jtopjian-mods https://github.com/jtopjian/puppetlabs-apache apache
git clone -b 3.x https://github.com/puppetlabs/puppetlabs-stdlib stdlib
git clone -b folsom https://github.com/jtopjian/puppetlabs-glance glance
git clone -b folsom https://github.com/jtopjian/puppetlabs-keystone keystone
git clone -b folsom https://github.com/jtopjian/puppetlabs-nova nova
git clone -b folsom https://github.com/jtopjian/puppet-cinder cinder
git clone -b folsom https://github.com/jtopjian/puppetlabs-nova nova
git clone -b folsom https://github.com/puppetlabs/puppetlabs-horizon horizon
git clone -b folsom https://github.com/jtopjian/puppetlabs-openstack openstack
git clone https://github.com/jtopjian/jtopjian-fqdn_underscore fqdn_underscore
git clone https://github.com/puppetlabs/puppetlabs-rabbitmq rabbitmq
git clone https://github.com/puppetlabs/puppetlabs-mysql mysql
git clone https://github.com/puppetlabs/puppetlabs-git git
git clone https://github.com/puppetlabs/puppetlabs-vcsrepo vcsrepo
git clone https://github.com/saz/puppet-memcached memcached
git clone https://github.com/puppetlabs/puppetlabs-rsync rsync
git clone https://github.com/puppetlabs/puppetlabs-xinetd xinetd
git clone https://github.com/saz/puppet-ssh ssh
git clone https://github.com/puppetlabs/puppetlabs-stdlib stdlib
git clone https://github.com/puppetlabs/puppetlabs-apt apt
git clone https://github.com/ripienaar/puppet-concat concat
git clone https://github.com/duritong/puppet-sysctl.git  sysctl
git clone https://github.com/jamtur01/puppet-httpauth httpauth
git clone https://github.com/puppetlabs/puppetlabs-ntp ntp
git clone https://github.com/puppetlabs/puppetlabs-passenger passenger
git clone https://github.com/jtopjian/puppetlabs-dashboard dashboard
git clone https://github.com/puppetlabs/puppetlabs-firewall firewall
git clone https://github.com/cprice-puppet/puppetlabs-inifile inifile
git clone https://github.com/puppetlabs/puppetlabs-puppetdb puppetdb
wget http://forge.puppetlabs.com/system/releases/p/puppetlabs/puppetlabs-ruby-0.0.1.tar.gz
tar xzvf puppetlabs-ruby-0.0.1.tar.gz
mv puppetlabs-ruby-0.0.1 ruby
rm puppetlabs-ruby-0.0.1.tar.gz

# Enable IP forwarding
sed -i -e 's/^#net.ipv4.ip_forward=1$/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p
