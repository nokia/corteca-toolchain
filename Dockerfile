# Copyright 2024 Nokia
# Licensed under the BSD 3-Clause License.
# SPDX-License-Identifier: BSD-3-Clause

FROM debian:bookworm-slim
LABEL maintainer="Nokia"

ARG BUILDROOT_VERSION=2023.02.1
ARG PARALLEL_PROCS=4
ARG DEVICE_CONFIG
ARG REBUILD_BUILDROOT=yes
ARG DOCKER_USER=user

ENV DEBIAN_FRONTEND=noninteractive
ENV BUILDROOT_VERSION=${BUILDROOT_VERSION}
ENV PARALLEL_PROCS=${PARALLEL_PROCS}
ENV DEVICE_CONFIG=${DEVICE_CONFIG}
ENV PATH="${PATH}:/buildroot/output/host/bin"

COPY --chmod=0755 scripts/nokia_toolchain.sh /usr/bin/nokia_toolchain
COPY --chmod=0755 config/${DEVICE_CONFIG}.config /etc/buildroot.config
COPY --chmod=0644 environments/${DEVICE_CONFIG}.env /etc/target.env

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    bc \
    ca-certificates \
    cpio \
    curl \
    file \
    gcc-aarch64-linux-gnu \
    gcc-arm-linux-gnueabi \
    git \
    jq \
    rsync \
    xz-utils \
    wget \
    unzip \
    dirmngr \
    fakeroot \
    less \
    pkg-config \
    pkgconf && \
    apt-get install --no-install-recommends -y \
    golang-go \
    binutils \
    binutils-x86-64-linux-gnu \
    cpp \
    g++ \
    gcc \
    golang-go \
    golang-src \
    libgcc-12-dev \
    libstdc++-12-dev \
    rpcsvc-proto && \
    apt-get install -y \
    build-essential \
    libncurses5-dev && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /buildroot /app && \
    addgroup ${DOCKER_USER} && adduser ${DOCKER_USER} --ingroup ${DOCKER_USER} && \
    echo 'export PATH=${PATH}:/buildroot/output/host/bin' >> /etc/bash.bashrc && \
    echo "PS1='"'${debian_chroot:+($debian_chroot)}\u@${DEVICE_CONFIG}:\w\$ '"'" >> /etc/bash.bashrc && \
    echo "source /etc/target.env" >> /etc/bash.bashrc && \
    chown ${DOCKER_USER}:${DOCKER_USER} /buildroot && \
    chown ${DOCKER_USER}:${DOCKER_USER} /app

USER $DOCKER_USER

RUN curl https://buildroot.org/downloads/buildroot-${BUILDROOT_VERSION}.tar.xz | \
    tar -C /buildroot -xvJ --strip-components=1 && \
    cp /etc/buildroot.config /buildroot/.config && \
    nokia_toolchain

WORKDIR /buildroot
ENTRYPOINT ["/bin/bash"]
CMD ["/usr/bin/nokia_toolchain", "build_app"]
