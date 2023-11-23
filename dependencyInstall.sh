#!/bin/bash

# Make sure to enable the codeready builder RHEL repos first


OS_VERSION=$(cat /etc/os-release | grep ^VERSION_ID)
OS_VERSION=$(echo $OS_VERSION | rev | cut -d'=' -f1 | rev)
OS_VERSION=$(sed -e 's/^"//' -e 's/"$//' <<<"$OS_VERSION")
OS_VERSION_MAJOR=$(echo $OS_VERSION | cut -d'.' -f1)
echo "OS version: $OS_VERSION"

# The following packages are currently missing on RHEL9
if [ $OS_VERSION_MAJOR -eq 9 ]
then
    echo "Installing packages missing in RHEL 9 ..."
    dnf -y install boost-devel cmake giflib-devel libXext-devel \
        libXt-devel libXtst-devel libraw1394 libtirpc-devel \
        libusb-devel libusbx-devel libxml2-devel motif-devel \
        net-snmp-devel opencv-devel pcre-devel re2c readline-devel \
        rpcgen xz-devel zeromq-devel

    # This is needed on RHEL9 since the opencv2 install dir has apparently changed
    ln -s /usr/include/opencv4/opencv2 /usr/include/opencv2
fi

# Needed for EPICS base + core modules
dnf -y install re2c readline-devel
dnf -y install libxml2-devel pcre-devel libtirpc-devel
dnf -y install libusbx-devel libXext-devel libjpeg-devel perl-devel
dnf -y install git wget tar make cmake gcc gcc-c++ pkgconfig
dnf -y install libraw1394 boost-devel libusb-devel rpcgen
dnf -y install qt5-qtbase-devel

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
