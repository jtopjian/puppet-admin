#!/bin/bash

cd /root

# Install basic packages
apt-get update
apt-get install -y puppet git rubygems rake

# Install required puppet modules
cd /etc/puppet/modules
git clone -b jtopjian-mods https://github.com/jtopjian/puppetlabs-puppet puppet
git clone -b jtopjian-mods https://github.com/jtopjian/puppetlabs-apache apache
git clone https://github.com/puppetlabs/puppetlabs-openstack openstack
cd openstack
rake modules:clone
cd ..
git clone https://github.com/jamtur01/puppet-httpauth
git clone https://github.com/puppetlabs/puppetlabs-ntp ntp
git clone https://github.com/puppetlabs/puppetlabs-passenger passenger
git clone https://github.com/jtopjian/puppetlabs-dashboard dashboard
git clone https://github.com/puppetlabs/puppetlabs-firewall firewall
wget http://forge.puppetlabs.com/system/releases/p/puppetlabs/puppetlabs-ruby-0.0.1.tar.gz
tar xzvf puppetlabs-ruby-0.0.1.tar.gz
mv puppetlabs-ruby-0.0.1 ruby
rm puppetlabs-ruby-0.0.1.tar.gz

# Enable IP forwarding
sed -i -e 's/^#net.ipv4.ip_forward=1$/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p
