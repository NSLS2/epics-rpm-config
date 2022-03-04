.PHONY: dirs generate_rpm generate_srpm generate_localinstall localinstall rpm srpm clean

dirs:
	mkdir -p BUILD INSTALL RESULT

generate_rpm:
	rpmbuild -v --define "_topdir %(pwd)" --define "_builddir %{_topdir}" --define "_rpmdir %{_topdir}" --define "_sourcedir %{_topdir}" --define "_specdir %{_topdir}/rpmbuild" --define "_srcrpmdir %{_topdir}" --define "_rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm" --define "debug_package %{nil}" -bb rpmbuild/epics-bundle.spec
	mv *.srpm RESULT/.

generate_srpm:
	rpmbuild -v --define "_topdir %(pwd)" --define "_builddir %{_topdir}" --define "_rpmdir %{_topdir}" --define "_sourcedir %{_topdir}" --define "_specdir %{_topdir}/rpmbuild" --define "_srcrpmdir %{_topdir}" --define "_rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.srpm" --define "debug_package %{nil}" -bs rpmbuild/epics-bundle.spec
	mv *.srpm RESULT/.

generate_localinstall:
	cd installSynApps && python3 installCLI.py -c .. -b ../BUILD -i ../INSTALL -p -f -y	

localinstall: dirs generate_localinstall

rpm: dirs generate_rpm

srpm: dirs generate_srpm


clean:
	rm -rf BUILD INSTALL BUILDROOT RESULT
