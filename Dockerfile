# Multi-stage build for EPICS bundle RPM
ARG ALMA_VERSION=8
FROM almalinux:${ALMA_VERSION} AS builder

# Enable PowerTools/CodeReady Builder repo and EPEL for additional packages
# Note: AlmaLinux 8 uses "powertools", AlmaLinux 9 uses "crb"
RUN dnf -y install dnf-plugins-core epel-release && \
    if [ "${ALMA_VERSION}" = "8" ]; then \
        dnf config-manager --set-enabled powertools; \
    else \
        dnf config-manager --set-enabled crb; \
    fi

# Install build dependencies including rpmdevtools
RUN dnf -y update && \
    dnf -y install re2c readline-devel libxml2-devel pcre-devel libtirpc-devel \
    libusbx-devel libXext-devel libjpeg-devel perl-devel git wget tar make \
    cmake gcc gcc-c++ pkgconfig libraw1394 boost-devel libusb-devel rpcgen \
    net-snmp-devel motif-devel libXt-devel zeromq-devel giflib-devel \
    libXtst-devel python3 rpm-build rpmdevtools && \
    dnf -y install perl-FindBin perl-Pod-Html perl-Getopt-Long perl-Data-Dumper || true && \
    dnf clean all

# Install git-rpm-tools from NSLS2 repository
RUN git clone https://github.com/NSLS2/git-rpm-tools.git /tmp/git-rpm-tools && \
    cd /tmp/git-rpm-tools && \
    make rpm && \
    dnf -y install *.rpm && \
    cd / && rm -rf /tmp/git-rpm-tools

# Set working directory
WORKDIR /build

# Copy source code (installSynApps submodule needs to be present)
COPY . .

# Fix submodule - Docker COPY breaks git submodule structure, so clone it directly
RUN git config --global --add safe.directory /build && \
    SUBMODULE_URL=$(git config -f .gitmodules submodule.installSynApps.url) && \
    SUBMODULE_COMMIT=$(git ls-tree HEAD installSynApps | awk '{print $3}') && \
    rm -rf installSynApps && \
    git clone $SUBMODULE_URL installSynApps && \
    cd installSynApps && \
    git checkout $SUBMODULE_COMMIT && \
    cd /build && \
    git checkout -b build-branch || true

# Build the RPM using git-rpm-tools with memory-optimized compilation
# -j1: Single-threaded compilation to reduce memory usage
# -O0: No optimization to minimize compiler memory consumption
# -g0: No debug symbols to reduce memory and binary size
ENV MAKEFLAGS="-j1"
ENV CXXFLAGS="-O0 -g0"
ENV CFLAGS="-O0 -g0"
RUN make rpm && \
    mkdir -p /rpms && \
    cp *.rpm /rpms/ && \
    rm -rf rpmbuildtree BUILD INSTALL && \
    dnf -y install perl && dnf -y install /rpms/*.rpm

# Final stage - runtime image
ARG ALMA_VERSION=8
FROM almalinux:${ALMA_VERSION}

# Copy RPM from builder stage for extraction by CI workflow
COPY --from=builder /rpms /rpms

# Enable PowerTools/CodeReady Builder repo and EPEL for additional packages
# Note: AlmaLinux 8 uses "powertools", AlmaLinux 9 uses "crb"
RUN dnf -y install dnf-plugins-core epel-release && \
    if [ "${ALMA_VERSION}" = "8" ]; then \
        dnf config-manager --set-enabled powertools; \
    else \
        dnf config-manager --set-enabled crb; \
    fi

# Install runtime dependencies and development tools
RUN dnf -y update && \
    dnf -y install bash boost giflib libraw1394 libtirpc libusb libusbx \
    libXext libxml2 libXt libXtst motif net-snmp-libs pcre perl re2c \
    readline rpcgen zeromq python39 python39-pip && \
    dnf -y install python3-requests python3-pyyaml python3-dnf && \
    dnf -y install procServ git libxml2-devel libXext-devel zlib-devel libX11-devel && \
    dnf -y groupinstall "Development Tools" && \
    dnf -y install gcc gcc-c++ make readline-devel && \
    dnf -y install seq || true && \
    dnf clean all

# Copy EPICS installation from builder stage
COPY --from=builder /usr/lib64/epics /usr/lib64/epics
COPY --from=builder /usr/lib/epics /usr/lib/epics
COPY --from=builder /usr/bin/caget /usr/bin/caget
COPY --from=builder /usr/bin/cainfo /usr/bin/cainfo
COPY --from=builder /usr/bin/camonitor /usr/bin/camonitor
COPY --from=builder /usr/bin/caput /usr/bin/caput
COPY --from=builder /usr/bin/caRepeater /usr/bin/caRepeater
COPY --from=builder /usr/bin/casw /usr/bin/casw
COPY --from=builder /usr/bin/pvget /usr/bin/pvget
COPY --from=builder /usr/bin/pvinfo /usr/bin/pvinfo
COPY --from=builder /usr/bin/pvmonitor /usr/bin/pvmonitor
COPY --from=builder /usr/bin/pvput /usr/bin/pvput
COPY --from=builder /usr/bin/pvlist /usr/bin/pvlist
COPY --from=builder /usr/bin/edm /usr/bin/edm
COPY --from=builder /usr/bin/medm /usr/bin/medm
COPY --from=builder /usr/bin/msi /usr/bin/msi
COPY --from=builder /usr/bin/makeBaseApp /usr/bin/makeBaseApp
COPY --from=builder /etc/ld.so.conf.d/epics-bundle-x86_64.conf /etc/ld.so.conf.d/epics-bundle-x86_64.conf

# Update library cache
RUN ldconfig

# Set environment variables
ENV EPICS_BASE=/usr/lib64/epics
ENV EPICS_HOST_ARCH=linux-x86_64
ENV PATH="${EPICS_BASE}/bin/${EPICS_HOST_ARCH}:${PATH}"
ENV EPICS_CA_ADDR_LIST="localhost"
ENV EPICS_CA_AUTO_ADDR_LIST="localhost"

# Create required directories and non-root user for running EPICS
RUN mkdir -p /epics/common /epics/modules && \
    useradd -r -s /bin/bash softioc-tst && \
    chown -R softioc-tst:softioc-tst /epics
USER softioc-tst

WORKDIR /home/epics

CMD ["/bin/bash"]
