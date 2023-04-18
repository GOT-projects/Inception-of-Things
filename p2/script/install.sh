#!/bin/sh

echo [1]  install k3s
current_ip=$(/sbin/ip -o -4 addr list eth1 | awk '{print $4}' | cut -d/ -f1)
