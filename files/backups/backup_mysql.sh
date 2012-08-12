#!/bin/bash

filename="/var/lib/backups/mysql/mysql-`hostname`-`eval date +%Y%m%d`.sql.gz"
/usr/bin/mysqldump --opt --all-databases | gzip > $filename
