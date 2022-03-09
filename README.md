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
# This is only necessary the first time, it will install any required yum/dnf packages. Run with root/sudo/dzdo as needed
sudo ./dependencyInstall.sh

# This will install epics into the `INSTALL` directory. You can also use `make rpm` which will perform the local install and also generate an RPM
make localinstall
```

### Adding a Module

To add a module to the configuration, you will need a few things. First, perform the environment setup in the previous section.

Next, the module needs to be visible on the network either as a git repository (highly preferrable), or as a tarball that can be grabbed with wget. As an example, I will go through the process of adding the `optics` module located at `https://github.com/epics-modules/optics`.


Download and unpack your module in the `BUILD/support/` directory, and if applicable, check out your desired version. Then, edit the `configure/RELEASE` file to point to the built directories for any dependancy modules, navigate to it, and try to build with `make`. In addition, make sure there is a `SUPPORT` macro defined in `configure/RELEASE`. This is required since the tool will use it as a relative path to find any other modules.

For our optics example:

```
# Enter the support directory and clone the module
cd BUILD/support
git clone https://github.com/epics-modules/optics

# Check out the latest R2-13-5 tagged release
cd optics && git checkout -q R2-13-5
```

Next we edit the `optics/configure/RELEASE` file to point the locations of any dependencies, and we make sure a `SUPPORT` macro is defined (if not, you will need to add this to the upstream source location). In our example the edited file looks like:

```
SUPPORT=/epics/utils/rhel8-epics-config/BUILD/support

SNCSEQ=$(SUPPORT)/seq

CALC=$(SUPPORT)/calc

BUSY=$(SUPPORT)/busy

ASYN=$(SUPPORT)/asyn

#EPICS_BASE=/home/oxygen/MOONEY/epics/base-3.15.4
EPICS_BASE=/epics/utils/rhel8-epics-config/BUILD/base
```

Finally, we simply build with make

```
make -s
```

If this completes successfully, we can proceed to adding the module to the configuration permanently. Open the `INSTALL_CONFIG` file in the root of this repository. If the URL from which the module is pulled is already listed, add a line containing your module's information under it, in the same structure as the remaining modules. Otherwise, add a new URL and add your module's line under it. If it is a git repository, use `GIT_URL` otherwise, use `WGET_URL`.

For our `optics` example, it is under the `https://github.com/epics-modules` github org, which is already listed in the config file with `GIT_URL=https://github.com/epics-modules`. Under this we will add the following line:

```
OPTICS           R2-13-5              $(SUPPORT)/optics                        optics                   YES              YES              YES
```

The first item is the module name (this must be unique). Then the module version that will be checked out, then the module location in the build folder structure, then the module repository name, and finally the three binary options are whether we want to clone, build, and package the module respectively. In most cases these should all be `YES` aside from very specific cases where a module will install build artifacts into the output directories of another module (see `epics-extensions` as an example)


Once you have added the module to the install config, re-run the build script as above and make sure your module builds automatically successfully.

```
make clean
make localinstall
```

Note that only the top level `lib`, `bin`, `protocol`, `pmc`, `db`, `dbd`, and `include` folders will be included in the installation, so make sure your module installs any required build artifacts to their proper locations.

Once you have confirmed that the builds succeeds, the final step involves editing the rpm specfile to account for the change. Open `rpmbuild/epics-bundle.spec`, and make the following changes: 

* Change the `Release` number to one greater than the current value
* Add an entry to the changelog that accounts for the additional module. Make sure the version number listed in the changelog matches the one you edited in the previous step. In our example `optics` case:

```
* Tue May 18 2021 Jakub Wlodek <jwlodek@bnl.gov> - 0.1-5
- Adding optics module 
```

Now, you may want to generate an RPM that includes your new module to make sure it behaves as expected.

```
make clean
make rpm
```

Finally, once all of this is done, make a commit to your branch, push to your fork of `rhel8-epics-config`, and make a merge request with the master branch of the main repo. This will be reviewed and merged, and a new version of the RPM will be generated from the updated configuration
