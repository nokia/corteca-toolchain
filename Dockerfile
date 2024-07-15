# Copyright 2024 Nokia
# Licensed under the BSD 3-Clause License.
# SPDX-License-Identifier: BSD-3-Clause

ARG SOURCE=/usr/src
ARG DIST_USR=/dist/usr
ARG MIRROR_REGISTRY

FROM ${MIRROR_REGISTRY}alpine:3.17.7 AS alpine_toolchain_builder
ARG SOURCE
ARG DIST_USR
WORKDIR ${SOURCE}
RUN apk add build-base cmake file g++ gcc git jq json-c-dev \
    libc-dev make musl-dev && \
    mkdir -p ${SOURCE} ${DIST_USR}
RUN git clone https://git.openwrt.org/project/libubox.git && \
    cd libubox && git reset --hard d716ac4bc4236031d4c3cc1ed362b502e20e3787 && \
    mkdir ${SOURCE}/libubox-build && cd ${SOURCE}/libubox-build && \
    cmake ../libubox/ -DCMAKE_INSTALL_PREFIX=${DIST_USR} -DBUILD_LUA=OFF -DBUILD_EXAMPLES=OFF -DCMAKE_C_FLAGS="-Os -s" && \
    make && make install
RUN git clone https://git.openwrt.org/project/ubus.git && \
    cd ubus && git reset --hard a72457b61df045d3c499a6211362b751710590d7 && \
    mkdir ${SOURCE}/ubus-build && cd ${SOURCE}/ubus-build && \
    cmake ../ubus/ -DCMAKE_INSTALL_PREFIX=${DIST_USR} -DCMAKE_C_FLAGS="-Os -s" -DBUILD_LUA=OFF -DBUILD_EXAMPLES=OFF -DBUILD_STATIC=OFF && \
    make && make install
RUN find ${DIST_USR}/lib/ -name "*.a" -exec rm {} \;

FROM ${MIRROR_REGISTRY}alpine:3.17.7 AS alpine_toolchain
LABEL maintainer="Nokia"
LABEL org.opencontainers.image.source=https://github.com/nokia/corteca-toolchain
LABEL org.opencontainers.image.description="Nokia Corteca Toolchain images"
LABEL org.opencontainers.image.licenses=BSD-3-Clause
ARG DIST_USR
COPY --from=alpine_toolchain_builder ${DIST_USR} /usr
COPY --from=alpine_toolchain_builder ${DIST_USR} ${DIST_USR}
RUN apk add build-base cmake curl file g++ gcc git jq json-c-dev \
    libc-dev libgcc libstdc++ make musl-dev rsync tar unzip
ENV DIST_USR=${DIST_USR}