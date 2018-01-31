#!/bin/bash

if [[ ! -d /var/lib/nova/instances ]]; then
    mkdir -p /var/lib/nova/instances
fi

set -e
sudo -E /usr/bin/ait_mounts
