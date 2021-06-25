Name:           epics-bundle
Version:        0.1
Release:        6%{?dist}
Summary:        EPICS Base and Modules bundle

License:        BSD
URL:            https://code.nsls2.bnl.gov/epics-modules-nsls2/rhel8-epics-config
#Source0:        %{name}-%{version}.tar.gz

Patch0:         makeBaseApp-basepath.patch
Patch1:         disable-debug.patch

# TODO: actually populate proper dependencies
BuildRequires:  python3
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
if [ ! -d ./install/epics ]; then
    mkdir build
    mkdir install
    cd installSynApps
    python3 -u installCLI.py -y -c .. -b ../build -i ../install -p -f
    cd ../install
    mv EPICS_* epics
    cd epics
    patch -p1 < ../../rpmbuild/makeBaseApp-basepath.patch
    patch -p1 < ../../rpmbuild/disable-debug.patch
fi

%install
# Ignore invalid rpaths in EPICS build
export QA_RPATHS=$[ 0x0001 | 0x0002 ]
rm -rf %{buildroot}
mkdir -p %{buildroot}/usr/lib/epics
cp -r ./install/epics/* %{buildroot}/usr/lib/epics/.
mkdir -p %{buildroot}/usr/bin
cp ./install/epics/bin/linux-x86_64/{caget,cainfo,camonitor,caput,caRepeater,casw,pvget,pvinfo,pvmonitor,pvput,pvlist,edm,medm,msi} %{buildroot}/usr/bin/
cp ./install/epics/bin/linux-x86_64/makeBaseApp.pl %{buildroot}/usr/bin/makeBaseApp
mkdir -p %{buildroot}/etc/ld.so.conf.d
cp ./rpmbuild/epics-bundle.conf %{buildroot}/etc/ld.so.conf.d/.
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
