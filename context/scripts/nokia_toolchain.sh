#!/bin/bash
# Copyright 2024 Nokia
# Licensed under the BSD 3-Clause License.
# SPDX-License-Identifier: BSD-3-Clause

set -euo pipefail
umask 000

export GOMODCACHE="/tmp/gomodcache"
export GOCACHE="/tmp/gocache"
export BUILDROOT_PATH="/buildroot"
export APP_PATH="/app"
export DIST_PATH="${APP_PATH}/dist"
export TARGET_PATH="${APP_PATH}/target"
export TARGET_NOARCH_PATH="${TARGET_PATH}/noarch"
export TARGET_ARCH_PATH="${TARGET_PATH}/${DEVICE_CONFIG}"
export BUILD_BASE_PATH="${APP_PATH}/build"
export BUILD_ARCH_PATH="${BUILD_BASE_PATH}/${DEVICE_CONFIG}"
export BUILD_PATH="${BUILD_ARCH_PATH}/app"
export ROOTFS_PATH="${BUILD_ARCH_PATH}/rootfs"
export PKG_PATH="${BUILD_ARCH_PATH}/pkg"

mkdir -p "${BUILD_BASE_PATH}" "${TARGET_PATH}" "${BUILD_PATH}"

function menuconfig_buildroot {
    echo "Starting Buildroot make menuconfig"
    cd "${BUILDROOT_PATH}"
    make menuconfig
    set +u
    if [ -z "${DEVICE_CONFIG}" ]; then 
        DEVICE_CONFIG="$(date +"%Y-%m-%d-%H-%M-%S-%Z")"
    fi 
    set -u
    echo "Copying config to: ${BUILD_BASE_PATH}/"
    cp .config "${BUILD_BASE_PATH}/${DEVICE_CONFIG}.config"
}

function make_buildroot {
    echo "Building Buildroot"
    cd "${BUILDROOT_PATH}"
    make -j${PARALLEL_PROCS}
}

function make_app {
    # build the containerized application
    echo "Cross compile application"
    (cd "${APP_PATH}" && source /etc/target.env && make clean BUILD_PATH="${BUILD_PATH}" && make BUILD_PATH="${BUILD_PATH}")
}

function extract_rootfs {
    echo "extracting rootfs"
    cd "${BUILDROOT_PATH}"
    mkdir -p "${ROOTFS_PATH}"
    tar -C "${ROOTFS_PATH}" -xvf output/images/rootfs.tar > /dev/null
}

function prepare_container_rootfs {
    # create the rootfs that includes the application binaries
    echo "Create rootfs with the application"
    [ "$(ls -A "${TARGET_NOARCH_PATH}")" ] && cp -axv "${TARGET_NOARCH_PATH}"/* "${ROOTFS_PATH}/"
    [ "$(ls -A "${TARGET_ARCH_PATH}")" ] && cp -axv "${TARGET_ARCH_PATH}"/* "${ROOTFS_PATH}/"
    [ "$(ls -A "${BUILD_PATH}")" ] && cp -axv "${BUILD_PATH}"/* "${ROOTFS_PATH}/"
    cd "${ROOTFS_PATH}"
    if [ "${TARGET_LIBC}" == "musl" ]; then
        if [ "${GOARCH}" == "arm" ]; then
            (cd lib && [ -f ld-linux.so.3 ] || ln -s libc.so ld-linux.so.3)
        fi
        if [ "${GOARCH}" == "arm64" ]; then
            (cd lib && [ -f ld-linux-aarch64.so.1 ] || ln -s libc.so ld-linux-aarch64.so.1)
        fi
    fi
    mkdir -p "${PKG_PATH}"
    tar -cvzpf "${PKG_PATH}/rootfs.tar.gz" *  > /dev/null
    cp "${APP_PATH}/ADF" "${PKG_PATH}/"
}

function create_package {
    echo "Create the application package in ${DIST_PATH}"
    ADF=$(<"${PKG_PATH}/ADF")
    APP_NAME=$(jq -r '.annotations."com.nokia.app_name"'<<<${ADF})
    VERSION=$(jq -r '.annotations."com.nokia.app_version"'<<<${ADF})
    PKG_FILE=$(jq -r '.annotations."com.nokia.embedded_package".name'<<<${ADF})
    APP_PACKAGE="${APP_NAME}-${VERSION}-${DEVICE_CONFIG}-${PKG_FILE}"
    echo "Package name: ${APP_PACKAGE}"
    mkdir -p "${DIST_PATH}"
    cd "${PKG_PATH}" && tar -cvzf "${DIST_PATH}/${APP_PACKAGE}" ADF rootfs.tar.gz > /dev/null
}

source /etc/target.env

set +u
if [ ! -z "${MENUCONFIG}" ]; then
    REBUILD_BUILDROOT="${MENUCONFIG}"
    echo "Forced to run make menuconfig for Buildroot"
fi

# if there is no configuration, run make menuconfig and copy the file to /output
set +u
if [ ! -r "${BUILDROOT_PATH}/.config" ]; then
    echo "Buildroot .config not found, will run make menuconfig"
    export MENUCONFIG="yes"
fi

if [ $# -ge 1 ]; then
    if [ "$1" == "menuconfig" ]; then
        echo "Requested make menuconfig"
        export MENUCONFIG="yes"
    fi
    if [ "$1" == "make_buildroot" ]; then
        export REBUILD_BUILDROOT="yes"
    fi
fi

set +u
if [ ! -z "${MENUCONFIG}" ]; then
    menuconfig_buildroot
fi

# if REBUILD_BUILDROOT is set, run make on the buildroot
set +u
if [ ! -z "${REBUILD_BUILDROOT}" ]; then
    echo "Forced to build Buildroot"
    make_buildroot
fi
set -u

if [ $# -ge 1 ]; then
    if [ "$1" == "build_app" ]; then
        echo "Start building the app and creating the container"
        make_app
        extract_rootfs
        prepare_container_rootfs
        create_package
    fi
    if [ "$1" == "clean" ]; then
        echo "make clean"
        (cd "${APP_PATH}" && source /etc/target.env && make clean BUILD_PATH="${BUILD_PATH}")
    fi
    if [ "$1" == "distclean" ]; then
        echo "Cleaning up all artifacts"
        (cd "${APP_PATH}" && source /etc/target.env && make distclean)
    fi
fi
