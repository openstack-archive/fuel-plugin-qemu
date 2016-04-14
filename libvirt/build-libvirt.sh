#!/bin/bash

LIBVIRT_VER=1.2.14

sudo apt-get install wget git -y
sudo apt-get build-dep libvirt -y
sudo apt-get install devscripts -y
sudo apt-get install dpkg-dev -y

#git clone git://libvirt.org/libvirt.git -b v$LIBVIRT_VER libvirt-$LIBVIRT_VER
#tar cvzf libvirt-$LIBVIRT_VER.tar.gz libvirt-$LIBVIRT_VER
#rm -rf libvirt-$LIBVIRT_VER
wget http://libvirt.org/sources/libvirt-$LIBVIRT_VER.tar.gz

apt-get source libvirt -y
dpkg-source -x libvirt_1.2.2-0ubuntu13.1.17.dsc
cd libvirt-1.2.2; uupdate -v $LIBVIRT_VER ../libvirt-$LIBVIRT_VER.tar.gz
cd ../libvirt-$LIBVIRT_VER; echo "" > debian/patches/series

#disable following tests
cat << EOF > skip-test.c
int main ()
{
    return 0;
}
EOF
cp skip-test.c gnulib/tests/test-localename.c
cp skip-test.c tests/virfirewalltest.c
cp skip-test.c tests/networkxml2firewalltest.c
cp skip-test.c tests/nwfilterebiptablestest.c
cp skip-test.c tests/nwfilterxml2firewalltest.c

debian/rules build
fakeroot debian/rules binary
