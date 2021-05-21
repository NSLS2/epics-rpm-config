# EPICS Configuration for RHEL 8

<a href="https://jenkins.nsls2.bnl.gov/job/EPICS_SPEC/">
   <img src="https://jenkins.nsls2.bnl.gov/job/EPICS_SPEC/badge/icon" alt="Jenkins Build Status">
</a>


This repository reflects the current configuration of EPICS base + modules used to create the `epics-bundle` rpm.
It is synced with several Jenkins projects that execute the build, package it as an RPM, and then sign and upload the rpm.

### Test Environmnet Setup

Before performing any work on the configuration, you may want to set up a test environment. First, clone this repository,
and make a new development branch. You may also want to fork this repository first instead, and clone from there.

```
git clone https://code.nsls2.bnl.gov/epics-modules-nsls2/rhel8-epics-config
cd rhel8-epics-config
git submodule init && git submodule update
git checkout -b my-dev-branch
```

Next, run the build in order to get an EPICS installation on your system:

```
# This is only necessary the first time, it will install any required yum/dnf packages
./dependencyInstall.sh

mkdir build
mkdir install
cd installSynApps
./installCLI.py -c .. -b ../build -i ../install -p -f -y
```

You may also add the `-d` flag to the `installCLI` call to have the tool print debug messages. On a system with memory constraints, add
the `-t #` flag to the command as well, where `#` is the number of threads you wish to use. Without this flag, the build will use
as many threads as it can, which will accelerate the build process, but may use up to 12 GB of memory at peak. Once the build/installation is
finished, you should see the typical EPICS packaging flat structure in `install`, and a folder-per-module structure in `build`.

### Adding a Module

To add a module to the configuration, you will need a few things. First, perform the environment setup in the previous section.
Next, the module needs to be visible on the network either as a git repository (highly preferrable), or as a tarball that can be
grabbed with wget. Download and unpack your module in the `build/support/` directory, edit the `configure/RELEASE` file to point to 
the built directories for any dependancy modules, navigate to it, and try to build with `make`. In addition, make sure there is a
`SUPPORT` macro defined in `configure/RELEASE`. This is required since the tool will use it as a relative path to find any other modules.


If this completes successfully, open the `INSTALL_CONFIG` file. If the URL from which the module is pulled is already listed, add a 
line containing your module's information under it, in the same structure as the remaining modules. Otherwise, add a new URL and add your
module's line under it. If it is a git repository, use `GIT_URL` otherwise, use `WGET_URL`.

Once you have added the module to the install config, re-run the build script as above and make sure your module builds successfully.

Note that only the top level `lib`, `bin`, `protocol`, `pmc`, `db`, `dbd`, and `include` folders will be included in the installation,
so make sure your module installs any required build artifacts to their proper locations.

Once you have confirmed that the builds succeeds, make a commit to your branch, push to gitlab, and make a merge request with the master
branch of the main fork.
