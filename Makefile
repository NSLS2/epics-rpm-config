.PHONY: dirs localinstall bundle flatbundle rpm srpm clean updateversions

rpm:
	git-rpm-tools -a -d -n epics-bundle bb

srpm:
	git-rpm-tools -a -d -n epics-bundle bs

dirs:
	mkdir -p BUILD INSTALL RESULT

updateversions:
	cd installSynApps && python3 installCLI.py -c .. -v

localinstall: dirs
	cd installSynApps && python3 installCLI.py -c .. -b ../BUILD -i ../INSTALL -p -f -y

bundle: dirs
	cd installSynApps && python3 installCLI.py -c .. -b ../BUILD -i ../INSTALL -p -y -a

flatbundle: dirs
	cd installSynApps && python3 installCLI.py -c .. -b ../BUILD -i ../INSTALL -p -y -f -a

clean:
	rm -rf BUILD INSTALL RESULT rpmbuildtree *.rpm
