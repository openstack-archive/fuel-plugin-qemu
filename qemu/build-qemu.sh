#!/bin/bash

wget http://wiki.qemu-project.org/download/qemu-2.2.1.tar.bz2
sudo apt-get source qemu -y
sudo apt-get build-dep qemu -y
sudo apt-get install devscripts -y
sudo apt-get install dpkg-dev -y
sudo dpkg-source -x qemu_2.0.0+dfsg-2ubuntu1.21.dsc
cd qemu-2.0.0+dfsg; sudo uupdate -v 2.2.1 ../qemu-2.2.1.tar.bz2
cd ../qemu-2.2.1; sudo echo "">> debian/patches/series
sudo sed -i 's/seccomp="yes"/seccomp="no"/' configure
sudo debian/rules build
sudo fakeroot debian/rules binary
