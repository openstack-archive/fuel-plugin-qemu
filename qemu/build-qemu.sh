#!/bin/bash

wget http://kr.archive.ubuntu.com/ubuntu/pool/main/libt/libtool/libtool_2.4.2-1.11_all.deb
wget http://kr.archive.ubuntu.com/ubuntu/pool/main/libt/libtool/libtool-bin_2.4.2-1.11_amd64.deb
sudo dpkg -i libtool_2.4.2-1.11_all.deb
sudo dpkg -i libtool-bin_2.4.2-1.11_amd64.deb
dpkg-source -x qemu_2.4+dfsg-4ubuntu1.dsc
cd /qemu-2.4+dfsg;sudo dpkg-buildpackage
