#!/bin/bash

# Make sure to enable the codeready builder RHEL repos first

# Needed for EPICS base + core modules
dnf -y install re2c readline-devel
dnf -y install libxml2-devel pcre-devel libtirpc-devel
dnf -y install libusbx-devel libXext-devel libjpeg-devel perl-devel
dnf -y install git wget tar make cmake gcc gcc-c++ pkgconfig
dnf -y install libraw1394 boost-devel libusb-devel rpcgen

# Needed for SNMP EPICS module
dnf -y install net-snmp-devel

# Needed for MEDM
dnf -y install motif-devel libXt-devel

# Needed for ADEiger - Enable the EPEL repository if it hasn't been already
dnf -y install zeromq-devel

# Needed for edm
dnf -y install giflib-devel libXtst-devel

# Needed for ADCompVision
dnf -y install opencv-devel

# Needed for ffmpegServer
dnf -y install xz-devel

