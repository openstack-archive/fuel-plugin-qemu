#!/bin/bash

FROM ubuntu:14.04.3
RUN apt-get update
RUN apt-get install -y software-properties-common python-software-properties \
    make python-setuptools python-all dpkg-dev debhelper \
    fuseiso git genisoimage bind9-host wget curl lintian tmux lxc iptables \
    ca-certificates sudo apt-utils lsb-release autotools-dev device-tree-compiler texinfo acpica-tools libaio-dev libasound2-dev libattr1-dev libbluetooth-dev libbrlapi-dev libcap-dev libcap-ng-dev libcurl4-gnutls-dev libfdt-dev libncurses5-dev libnss3-dev libpixman-1-dev libpulse-dev librados-dev librbd-dev libsasl2-dev libsdl1.2-dev libseccomp-dev libspice-server-dev libspice-protocol-dev libusb-1.0-0-dev  libusbredirparser-dev libx11-dev libxen-dev libnuma-dev uuid-dev xfslibs-dev zlib1g-dev libjpeg-dev libpng12-dev

RUN echo "ALL ALL=NOPASSWD: ALL" > /etc/sudoers.d/open-sudo
RUN chmod 0440 /etc/sudoers.d/open-sudo

ADD ./download-qemu.sh /root/download-qemu.sh
RUN chmod +x /root/download-qemu.sh
RUN /root/download-qemu.sh


ADD ./build-qemu.sh /root/build-qemu.sh
RUN chmod +x /root/build-qemu.sh
RUN /root/build-qemu.sh
