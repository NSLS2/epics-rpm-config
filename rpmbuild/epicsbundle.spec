Name:           epicsbundle
Version:        1
Release:        2%{?dist}
Summary:        EPICS Base and Modules bundle

License:        BSD
#URL:            
Source0:        %{name}-%{version}.tar.gz

Patch0:         makeBaseApp-basepath.patch

#BuildRequires:  
Requires:       bash

BuildArch:      x86_64
#ExclusiveArch:  x86_64

# Prevent rpmbuild from smart-generating dependencies list
AutoReq:        no

# Prevent rpmbuild from auto-mangling executable shebangs
%undefine __brp_mangle_shebangs

%description
EPICS bundle packaged as RPM.

%prep
%autosetup -p1

%build
# %%configure
# %%make_build


%install
# Ignore invalid rpaths in EPICS build
export QA_RPATHS=$[ 0x0002 ]
rm -rf %{buildroot}
mkdir -p %{buildroot}/usr/lib/epics
cp -r ./* %{buildroot}/usr/lib/epics/
mkdir -p %{buildroot}/usr/bin
cp ./bin/linux-x86_64/{caget,cainfo,camonitor,caput,caRepeater,casw,pvget,pvinfo,pvmonitor,pvput,pvlist} %{buildroot}/usr/bin/
cp ./bin/linux-x86_64/makeBaseApp.pl %{buildroot}/usr/bin/makeBaseApp
mkdir -p %{buildroot}/lib64
cp ./lib/linux-x86_64/{libca.so.*,libCom.so.*,libpvAccessCA.so.*,libpvAccess.so.*,libpvData.so.*} %{buildroot}/lib64/

#cp ./bin/linux-x86_64/makeBaseApp %{buildroot}/usr/bin/
#sed -i "s|$base = '';|$base = '/usr/lib/epics';|g" makeBaseApp
#sed -i 's|$epics_base = $command;|$epics_base = "/usr/lib/epics";|g' makeBaseApp
#sed -i 's|^use lib.*|use lib ("/usr/lib/epics/lib/perl")|g' makeBaseApp

# %%make_install

%files
%license LICENSE
%doc README
%dir /usr/lib/epics
/usr/lib/epics/*
/usr/bin/*
/lib64/*

%changelog
* Tue Apr 27 2021 Anton Derbenev <aderbenev@bnl.gov> - 1-2
- Smarter installation and makeBaseApp patch

* Fri Apr 16 2021 Anton Derbenev <aderbenev@bnl.gov> - 1-1
- Initial relase of RPM
