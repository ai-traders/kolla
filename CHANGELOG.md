### 5.0.2.9 (2018-Apr-15)

 * revert to official ubuntu:16.04

### 5.0.2.8 (2018-Apr-14)

 * rebuild with ceph packages built with debase image.
 * moved config, overrides, changelog, pipeline and tasks to this repo

### 5.0.2.7 (2018-Apr-13)

 * fix kvm group permissions in nova-libvirt \#12641
 * install fwass from git, branch stable/pike
 * added /sbin/mkfs.none to nova-compute image
 * nova-libvirt supports ssh server for windows spice access
 * use blitznote/debase as base image to make images lighter and faster
 * use ceph from ait sources, built from source
 * drop barbican and etcd from built image set
 * nova and cinder back to official tarballs.
 * neutron upgraded to `11.0.3`
 * lock `neutron-fwaas-11.0.1`

### 5.0.2.6 (2018-Mar-13)

 * ceph creates backdoor user
 * ceph admin has mgr access by default
 * updated gnocchi to 4.2.1

### 5.0.2.5 (2018-Feb-24)

 * added smartmon tools and sensors to collectd image \#12473
 * added thin-provisioning-tools to nova-compute, needed for sparse lvm volumes
 * ceph external bluestore db devices detection \#12463
 * add bc and fix lvm config for docker
 * bump ceph to luminous 12.2.2
   - added ceph-volume util
   - use ceph apt
   - adds ceph-mgr image
 * added senlin to ait profile
 * Upgraded and locked source versions:  
   * aodh-5.1.0
   * ceilometer-9.0.4
   * designate-5.0.1
   * glance-15.0.1
   * horizon-12.0.2
   * heat-9.0.3
   * designate-dashboard-5.0.1
   * neutron-fwaas-dashboard-stable-pike release from 2017-11-30 22:08
   * neutron-lbaas-dashboard-stable-pike from 2017-12-20 00:50
   * senlin-dashboard-stable-pike from 2017-08-27 02:55
   * neutron-11.0.2
   * neutron-lbaas-11.0.2

### 5.0.2.4 (2018-Feb-6)

 * added glusterfs and swiftonfile to swift base image

### 5.0.2.3 (2018-Feb-2)

 * fix LVM in nova-compute to not use udev

### 5.0.2.2 (2018-Feb-2)

 * Added glusterfs to nova-libvirt,nova-compute,glance-api,cinder-volume images.
 * Switched to ait fork for nova-compute and cinder to support glusterfs

### 5.0.2.1 (2018-Jan-15)

Added `fluent-plugin-gelf-hs` to fluentd image.

### 5.0.2.0 (2018-Jan-13)

Initial release. Official images built from source.
