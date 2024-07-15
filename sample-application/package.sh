#!/bin/bash
set -euo pipefail

# Default
output_format="rootfs"

if [ $# -ge 1 ]; then
  case $1 in
    rootfs)
      output_format="rootfs"
      ;;
    oci-img)
      output_format="oci-img"
      ;;
    *)
      echo "Invalid argument. Use 'rootfs' for root filesystem or 'oci-img' for OCI image."
      exit 1
      ;;
  esac
fi

PKG_PATH="./dist"
ROOTFS_PATH="./dist/rootfs"
APP_PATH="."

APP_NAME=$(jq -r '.annotations."com.nokia.app_name"' "${APP_PATH}/ADF")
VERSION=$(jq -r '.annotations."com.nokia.app_version"' "${APP_PATH}/ADF")
PKG_FILE=$(jq -r '.annotations."com.nokia.embedded_package".name' "${APP_PATH}/ADF")
APP_PACKAGE="${APP_NAME}-${VERSION}-${ARCH}-${PKG_FILE}"

if [ "$output_format" == "rootfs" ]; then
    rm -fr "${PKG_PATH}" && mkdir -p "${ROOTFS_PATH}"
    docker buildx build --build-arg="ARCH=${ARCH}" --build-arg "ALPINE_PLATFORM=${ALPINE_PLATFORM}" --build-arg "DOCKER_PLATFORM=${DOCKER_PLATFORM}" --platform "${DOCKER_PLATFORM}" -f Dockerfile --output "type=local,dest=${ROOTFS_PATH}" .
    
    (cd "${PKG_PATH}"; tar -czvf rootfs.tar.gz -C rootfs/ .)
    cp "${APP_PATH}/ADF" "${PKG_PATH}/ADF"
    tar -C "${PKG_PATH}" -cvzf "${PKG_PATH}/${APP_PACKAGE}" ADF rootfs.tar.gz && chmod 666 "${PKG_PATH}/${APP_PACKAGE}"
    
    echo "Rootfs package created: ${PKG_PATH}/${APP_PACKAGE}"
elif [ "$output_format" == "oci-img" ]; then
    docker buildx build --build-arg="ARCH=${ARCH}" --build-arg "ALPINE_PLATFORM=${ALPINE_PLATFORM}" --build-arg "DOCKER_PLATFORM=${DOCKER_PLATFORM}" --platform "${DOCKER_PLATFORM}" -f Dockerfile -t "${APP_NAME}-${ARCH}:${VERSION}" .
    
    echo "OCI image tagged: ${APP_NAME}-${ARCH}:${VERSION}"
fi
