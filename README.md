# NSLS2 EPICS Bundle RPM Configuration

This repository reflects the current configuration of EPICS base + modules used to create the `epics-bundle` rpm.
It is synced with several Jenkins projects that execute the build, package it as an RPM, and then sign and upload the rpm.

### Test Environmnet Setup

Before performing any work on the configuration, you may want to set up a test environment. First, clone this repository,
and make a new development branch. You may also want to fork this repository first instead, and clone from there.

```
git clone --recursive https://github.com/NSLS2/epics-rpm-config
cd epics-rpm-config
git checkout -b my-dev-branch
```

Next, run the build in order to get an EPICS installation on your system:

```
# This is only necessary the first time, it will install any required yum/dnf packages. Run this with root permissions
sudo ./dependencyInstall.sh

# This will install epics into the `INSTALL` directory. You can also use `make rpm` which will perform the local install and also generate an RPM
make localinstall
```

### Versioning Schema

Since each release of the `epics-bundle` rpm contains all of EPICS base and a large variety of modules and drivers, a scheme to represent the version of the package that could denote changes to any component needed to be devised. The solution ultimately became a three part version string, as follows:

1. The EPICS base version, followed by an underscore.
2. A three number string, each separated by periods, with the following meanings:
   * Addition/Removal of a module (potentially breaking change).
   * Change (i.e. version bump) of module with dependants.
   * Change to module with no dependants.
3. A minor release number, meant to signify non-invasive changes to specfile or build process.

With each change to the configuration, if the EPICS base version remains static the second version string component should be update as necessary. If the base version changes, the first component is changed, and each number in the second and third components is reset to 0.

For example, a version string of `7.0.4.1_1.3.1-4` would indicate:

* An EPICS base version of `7.0.4.1`.
* One module was added or removed since the intial release of the rpm with that EPICS base version.
* Three modules with dependants had their versions changed since the initial release of the rpm with that base version.
* One module without dependants had its version changed.
* There were 4 changes to the specfile or build tool.

### Adding a Module

To add a module to the configuration, you will need a few things. First, perform the environment setup in the previous section.

Next, the module needs to be visible on the network either as a git repository (highly preferrable), or as a tarball that can be grabbed with wget. As an example, I will go through the process of adding the `optics` module located at `https://github.com/epics-modules/optics`.


Download and unpack your module in the `BUILD/support/` directory, and if applicable, check out your desired version. Then, edit the `configure/RELEASE` file to point to the built directories for any dependancy modules, navigate to it, and try to build with `make`.

For our optics example:

```
# Enter the support directory and clone the module
cd BUILD/support
git clone https://github.com/epics-modules/optics

# Check out the R2-13-5 tagged release
cd optics && git checkout -q R2-13-5
```

Next we edit the `optics/configure/RELEASE` file to point the locations of any dependencies. In our example the edited file looks like:

```
SUPPORT=/epics/utils/rhel8-epics-config/BUILD/support

SNCSEQ=$(SUPPORT)/seq

CALC=$(SUPPORT)/calc

BUSY=$(SUPPORT)/busy

ASYN=$(SUPPORT)/asyn

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

The first item is the module name (this must be unique and match the name used in other module `RELEASE` files). Then the module version that will be checked out, then the module location in the build folder structure, then the module repository name, and finally the three binary options are whether we want to clone, build, and package the module respectively. In most cases these should all be `YES` aside from very specific cases where a module will install build artifacts into the output directories of another module (see `epics-extensions` as an example)


Once you have added the module to the install config, re-run the build script as above and make sure your module builds automatically successfully.

```
make clean
make localinstall
```

Note that only the top level `lib`, `bin`, `protocol`, `pmc`, `db`, `dbd`, and `include` folders will be included in the installation, so make sure your module installs any required build artifacts to their proper locations.

Once you have confirmed that the builds succeeds, the final step involves editing the rpm specfile to account for the change. Open `dist/epics-bundle.spec`, and make the following changes: 

* Update the `Version` and `Release` entries based on the versioning schema outlined above
* Add an entry to the changelog that accounts for the additional module. Make sure the version number listed in the changelog uses the versioning schema correctly. For example in the `optics` case:

```
* Tue May 18 2021 Jakub Wlodek <jwlodek@bnl.gov> - 7.0.5_1.0.0-0
- Adding optics module 
```

Now, you may want to generate an RPM that includes your new module to make sure it behaves as expected. To generate an rpm, you must first install `git-rpm-tools`:

```
sudo dnf install git-rpm-tools
```

And then, simply run:

```
make clean
make rpm
```

Finally, once all of this is done, make a commit to your branch, push to your fork of `epics-rpm-config`, and make a merge request with the main branch of the repo. This will be reviewed and merged, and a new version of the RPM will be generated from the updated configuration.


### Containers

**Pull and run the latest release:**

```bash
docker pull ghcr.io/nsls2/epics-alma8:latest
docker run -it ghcr.io/nsls2/epics-alma8:latest
```

**Build locally:**

```bash
# Initialize submodules first
git submodule update --init --recursive

# Build the container
docker build -t epics-alma8 .

# Run container
docker run -it epics-alma8
```
