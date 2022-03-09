.PHONY: dirs localinstall bundle flatbundle rpm srpm clean

dirs:
	mkdir -p BUILD INSTALL RESULT


localinstall: dirs
	cd installSynApps && python3 installCLI.py -c .. -b ../BUILD -i ../INSTALL -p -f -y	

bundle: dirs
	cd installSynApps && python3 installCLI.py -c .. -b ../BUILD -i ../INSTALL -p -y -a

flatbundle: dirs
	cd installSynApps && python3 installCLI.py -c .. -b ../BUILD -i ../INSTALL -p -y -f -a

rpm: dirs
	rpmbuild -v --define "_topdir %(pwd)" --define "_builddir %{_topdir}" --define "_rpmdir %{_topdir}" --define "_sourcedir %{_topdir}" --define "_specdir %{_topdir}/rpmbuild" --define "_srcrpmdir %{_topdir}" --define "_rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm" --define "debug_package %{nil}" -bb rpmbuild/epics-bundle.spec
	mv *.srpm RESULT/.

srpm: dirs
	rpmbuild -v --define "_topdir %(pwd)" --define "_builddir %{_topdir}" --define "_rpmdir %{_topdir}" --define "_sourcedir %{_topdir}" --define "_specdir %{_topdir}/rpmbuild" --define "_srcrpmdir %{_topdir}" --define "_rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.srpm" --define "debug_package %{nil}" -bs rpmbuild/epics-bundle.spec
	mv *.srpm RESULT/.


clean:
	rm -rf BUILD INSTALL BUILDROOT RESULT
