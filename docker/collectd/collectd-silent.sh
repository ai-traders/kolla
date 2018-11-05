#!/bin/bash

# In order to debug collectd, remove redirection below
/usr/sbin/collectd -f -C /etc/collectd/collectd.conf 2> /dev/null
