#!/bin/bash
# Ugly hack to put everything on one line
# Nagios3 should support this. Might look into later.

output=`nova-manage service list | grep XXX`
if [ $? -eq 0 ]; then
        echo "$output" | awk '{print $1,$2}' | while read LINE; do
                echo -n "$LINE; "
        done
        echo ""
        exit 2
else
        echo "All nodes up"
        exit 0
fi
