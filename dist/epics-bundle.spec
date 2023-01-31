Name:           epics-bundle
Version:        0.1
Release:        9%{?dist}
Summary:        EPICS Base and Modules bundle

License:        BSD
URL:            https://code.nsls2.bnl.gov/epics-modules-nsls2/rhel8-epics-config
#Source0:        %{name}-%{version}.tar.gz

BuildRequires:  python3 boost-devel cmake g++ gcc gcc-c++ giflib-devel git libboost-dev libboost-system-dev libboost-test-dev libdmtx-dev libjpeg-devel libopencv-dev libpcre3-dev libraw1394 libreadline-dev libtirpc-devel libusb-1.0-0-dev libusb-dev libusb-devel libusbx-devel libx11-dev libxext-dev libXext-devel libxml2-dev libxml2-devel libXt-devel libXtst-devel libzbar-dev make motif-devel net-snmp-devel pcre-devel perl-devel pkgconfig re2c readline-devel rpcgen tar wget zeromq-devel
Requires:       bash

BuildArch:      x86_64

# Prevent rpmbuild from smart-generating dependencies list
AutoReq:        no

# Prevent rpmbuild from auto-mangling executable shebangs
%undefine __brp_mangle_shebangs

%description
EPICS base and modules bundle packaged as RPM.

%prep
# %%autosetup -p1

%build
# %%configure
# %%make_build
if [ ! -d ./INSTALL/epics ]; then
    mkdir -p BUILD
    mkdir -p INSTALL
    cd installSynApps
    python3 -u installCLI.py -y -c .. -b ../BUILD -i ../INSTALL -p -f
    cd ../INSTALL
    mv EPICS_* epics
    cd epics
    patch -p1 < ../../dist/makeBaseApp-basepath.patch
    patch -p1 < ../../dist/disable-debug.patch
fi

%install
# Ignore invalid rpaths in EPICS build
export QA_RPATHS=$[ 0x0001 | 0x0002 ]
rm -rf %{buildroot}
mkdir -p %{buildroot}/usr/lib/epics
cp -r ./INSTALL/epics/* %{buildroot}/usr/lib/epics/.
mkdir -p %{buildroot}/usr/bin
cp ./INSTALL/epics/bin/linux-x86_64/{caget,cainfo,camonitor,caput,caRepeater,casw,pvget,pvinfo,pvmonitor,pvput,pvlist,edm,medm,msi} %{buildroot}/usr/bin/
cp ./INSTALL/epics/bin/linux-x86_64/makeBaseApp.pl %{buildroot}/usr/bin/makeBaseApp
mkdir -p %{buildroot}/etc/ld.so.conf.d
cp ./dist/epics-bundle.conf %{buildroot}/etc/ld.so.conf.d/.
#mkdir -p %{buildroot}/lib64
#cp ./install/epics/lib/linux-x86_64/lib*.so* %{buildroot}/lib64/
chmod u+w -R %{buildroot}

# %%make_install

%files
%dir /usr/lib/epics
/usr/lib/epics/*
/usr/bin/*
/etc/ld.so.conf.d/*
#/lib64/*

%changelog
* Tue Jan 31 2023 Derbenev, Anton <aderbenev@bnl.gov> - 0.1-9
- Revise specfile dir naming, sources and patches handling for git-mrt-tools compatibility

* Tue Jan 31 2023 Derbenev, Anton <aderbenev@bnl.gov> - 0.1-8
- Update Requires and BuildRequires

* Fri Mar 04 2022 Jakub Wlodek <jwlodek@bnl.gov> - 0.1-7
- Include autosave and areaDetector common iocBoot files

* Fri Jun 25 2021 Jakub Wlodek <jwlodek@bnl.gov> - 0.1-6
- Adding ezca and EzcaScan extension modules

* Tue May 18 2021 Jakub Wlodek <jwlodek@bnl.gov> - 0.1-5
- Adding optics module

* Thu May 06 2021 Anton Derbenev <aderbenev@bnl.gov> - 0.1-4
- Package rename to epics-bundle

* Mon May 3 2021 Anton Derbenev <aderbenev@bnl.gov> - 0.1-3
- Performing the source build during rpm build

* Tue Apr 27 2021 Anton Derbenev <aderbenev@bnl.gov> - 0.1-2
- Smarter installation and makeBaseApp patch

* Fri Apr 16 2021 Anton Derbenev <aderbenev@bnl.gov> - 0.1-1
- Initial relase of RPM
