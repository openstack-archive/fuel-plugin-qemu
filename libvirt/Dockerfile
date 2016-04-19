#!/bin/bash

FROM ubuntu:14.04.3
RUN apt-get update

RUN echo "ALL ALL=NOPASSWD: ALL" > /etc/sudoers.d/open-sudo
RUN chmod 0440 /etc/sudoers.d/open-sudo

ADD ./build-libvirt.sh /root/build-libvirt.sh
RUN chmod +x /root/build-libvirt.sh
RUN /root/build-libvirt.sh
