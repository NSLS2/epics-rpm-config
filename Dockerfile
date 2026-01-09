# Multi-stage build for EPICS bundle RPM
FROM almalinux:8 AS builder

# Enable PowerTools/CodeReady Builder repo and EPEL for additional packages
RUN dnf -y install dnf-plugins-core epel-release && \
    dnf config-manager --set-enabled powertools

# Install build dependencies including rpmdevtools
RUN dnf -y update && \
    dnf -y install re2c readline-devel libxml2-devel pcre-devel libtirpc-devel \
    libusbx-devel libXext-devel libjpeg-devel perl-devel git wget tar make \
    cmake gcc gcc-c++ pkgconfig libraw1394 boost-devel libusb-devel rpcgen \
    net-snmp-devel motif-devel libXt-devel zeromq-devel giflib-devel \
    libXtst-devel python3 rpm-build rpmdevtools libevent-devel && \
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
    make srpm && \
    mkdir -p /rpms && \
    mkdir -p /srpms/ && \
    cp *.rpm /rpms/ && \
    cp *.src.rpm /srpms/ && \
    rm -rf rpmbuildtree BUILD INSTALL

# Final stage - runtime image
FROM almalinux:8

# Copy RPM from builder stage for extraction by CI workflow
COPY --from=builder /rpms /rpms
COPY --from=builder /srpms /srpms

# Enable PowerTools/CodeReady Builder repo and EPEL for additional packages
RUN dnf -y install dnf-plugins-core epel-release && \
    dnf config-manager --set-enabled powertools

# Install runtime dependencies and development tools
RUN dnf -y update && dnf -y install /rpms/*.rpm && \
    dnf -y install perl wget tar make cmake gcc gcc-c++ pkgconfig git && \
    dnf -y install python3 && \
    dnf clean all

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
