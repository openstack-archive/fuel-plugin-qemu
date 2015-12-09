#!/bin/bash

FROM ubuntu:14.04.3
RUN apt-get update
RUN apt-get install -y git fakeroot build-essential ncurses-dev xz-utils kernel-package bc
RUN echo "ALL ALL=NOPASSWD: ALL" > /etc/sudoers.d/open-sudo
RUN chmod 0440 /etc/sudoers.d/open-sudo
ADD ./build_kvm.sh /root/build_kvm.sh
RUN chmod +x /root/build_kvm.sh
RUN /root/build_kvm.sh


