#!/bin/bash
wget http://wiki.qemu-project.org/download/qemu-2.2.1.tar.bz2
sudo apt-get build-dep qemu -y
sudo apt-get install devscripts -y
sudo apt-get install dpkg-dev -y
apt-get source qemu -y
dpkg-source -x qemu_2.0.0+dfsg-2ubuntu1.21.dsc
cd qemu-2.0.0+dfsg; uupdate -v 2.2.1 ../qemu-2.2.1.tar.bz2
cd ../qemu-2.2.1;echo "">> debian/patches/series
sed -i 's/seccomp="yes"/seccomp="no"/' configure
debian/rules build
fakeroot debian/rules binary
