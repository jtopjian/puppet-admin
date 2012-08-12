#!/bin/bash

puppet cert --clean $1
ssh-keygen -f "/etc/ssh/ssh_known_hosts" -R $1
ssh-keygen -f "/root/.ssh/known_hosts" -R $1
