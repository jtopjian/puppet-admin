#!/bin/sh
cd /usr/share/puppet-dashboard
/usr/bin/rake RAILS_ENV=production reports:prune upto=14 unit=day > /var/log/puppet/prune.log 2>&1
/usr/bin/rake RAILS_ENV=production db:raw:optimize > /var/log/puppet/prune.log 2>&1
find /var/lib/puppet/reports -ctime +14 -type f -delete
