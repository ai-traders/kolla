#!/bin/bash

AIT_KVM_GID=${AIT_KVM_GID:-113}

groupmod --gid ${AIT_KVM_GID} kvm

# Mount xenfs for libxl to work
if [[ $(lsmod | grep xenfs) ]]; then
    mount -t xenfs xenfs /proc/xen
fi

if [[ ! -d "/var/log/kolla/libvirt" ]]; then
    mkdir -p /var/log/kolla/libvirt
    touch /var/log/kolla/libvirt/libvirtd.log
    chmod 644 /var/log/kolla/libvirt/libvirtd.log
fi
if [[ $(stat -c %a /var/log/kolla/libvirt) != "755" ]]; then
    chmod 755 /var/log/kolla/libvirt
    chmod 644 /var/log/kolla/libvirt/libvirtd.log
fi

sudo -E /usr/bin/setup_ssh

set -e
sudo -E /usr/bin/ait_mounts
