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
git clone -b jtopjian-region https://github.com/jtopjian/puppetlabs-glance
git clone -b jtopjian-region https://github.com/jtopjian/puppetlabs-keystone
git clone -b jtopjian-region https://github.com/jtopjian/puppetlabs-nova
git clone https://github.com/jtopjian/jtopjian-fqdn_underscore fqdn_underscore
#git clone https://github.com/puppetlabs/puppetlabs-openstack openstack
#cd openstack
#rake modules:clone
#cd ..
git clone https://github.com/jamtur01/puppet-httpauth
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
gem install librarian-puppet
cd /etc/puppet
wget https://raw.github.com/bodepd/puppetlabs-openstack_dev_env/master/Puppetfile
librarian-puppet install

# Enable IP forwarding
sed -i -e 's/^#net.ipv4.ip_forward=1$/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p
