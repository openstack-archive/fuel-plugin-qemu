Qemu Plugin for Fuel
================================

Qemu plugin
-----------------------

Overview
--------

New fuel plugin fuel-plugin-qemu is developed to deploy QEMU >2.2 in Fuel@OPNFV, which is requested by OVS with DPDK.

Requirements
------------

| Requirement                      | Version/Comment |
|----------------------------------|-----------------|
| Mirantis OpenStack compatibility | 6.1             |

Recommendations
---------------

None.

Limitations
-----------

None.

Installation Guide
==================

Qemu plugin installation
----------------------------------------

1. Clone the fuel-plugin-qemu repo from stackforge:

        git clone https://github.com/stackforge/fuel-plugin-qemu

2. Install the Fuel Plugin Builder:

        pip install fuel-plugin-builder

3. Install the [fpm gem](https://github.com/jordansissel/fpm):

        gem install fpm
    
4. Build Qemu Fuel plugin:

        fpb --build fuel-plugin-qemu/

5. The *fuel-plugin-qemu-[x.x.x].rpm* plugin package will be created in the plugin folder.
  
6. Move this file to the Fuel Master node with secure copy (scp):

        scp fuel-plugin-qemu-[x.x.x].rpm root@<the_Fuel_Master_node_IP address>:/tmp

7. While logged in Fuel Master install the Qemu plugin:

        fuel plugins --install fuel-plugin-qemu-[x.x.x].rpm

8. Check if the plugin was installed successfully:

        fuel plugins

        id | name             | version | package_version
        ---|------------------|---------|----------------
        1  | fuel-plugin-qemu | 0.5.0   | 2.0.0

9. Plugin is ready to use and can be enabled on the Settings tab of the Fuel web UI.


User Guide
==========

Qemu plugin configuration
---------------------------------------------

1. Create a new environment with the Fuel UI wizard.
2. Click on the Settings tab of the Fuel web UI.
3. Scroll down the page, select the plugin checkbox. In case of centos, modify the priority of the mos repo.


Build options
-------------

It is possible to modify process of building plugin by setting environment variables. Look into [pre_build_hook file](pre_build_hook) for more details.

Dependencies
------------

If you plan to use plugin in environment without internet access or/and CentOS environment modify build command:

     INCLUDE_DEPENDENCIES=true fpb --build fuel-plugin-qemu/

Pre build script will try download required dependencies so it become part of the compiled plugin.

Note: List of packages for [ubuntu](qemu_package/ubuntu/dependencies.txt) and [centos](qemu_package/centos/dependencies.txt) may need to be modified if packages in centos or ubuntu repositories will change.

Testing
-------

None.

Known issues
------------

None.

Release Notes
-------------

**0.5.0**

* Initial release of the plugin. This is a beta version.


Development
===========

The *OpenStack Development Mailing List* is the preferred way to communicate,
emails should be sent to `openstack-dev@lists.openstack.org` with the subject
prefixed by `[fuel][plugins][qemu]`.

Reporting Bugs
--------------

Bugs should be filled on the [Launchpad fuel-plugins project](
https://bugs.launchpad.net/fuel-plugins) (not GitHub) with the tag `qemu`.


Contributing
------------

If you would like to contribute to the development of this Fuel plugin you must
follow the [OpenStack development workflow](
http://docs.openstack.org/infra/manual/developers.html#development-workflow).

Patch reviews take place on the [OpenStack gerrit](
https://review.openstack.org/#/q/status:open+project:stackforge/fuel-plugin-qemu,n,z)
system.

Contributors
------------

* ling.y.yu@intel.com,ruijing.guo@intel.com

