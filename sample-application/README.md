# Sample Container Application v23.12.1

This is a sample hello world application used to demonstrate the Corteca tooolchain functionality

## Directory structure

For your container application, the following structure shows the recommended layout.

```shell
├── dist/             # Compiled/generated artifacts
├── src/              # Application source code location
│   ├── helloworld.c
│   └── Makefile      # Application build configuration
├── target/           # Files to be copied verbatim to the application container filesystem
│   └── noarch/
├── tests/            # Functional and product testing scripts
├── ADF               # Application Descriptor File (will only be used by legacy containers)
├── Dockerfile        # Dockerfile to build the application container image based on the toolchain base image
├── Makefile          # Main makefile for the package
├── package.sh        # Script to facilitate the application build
└── README.md         # this file
```

## Building the container

If everything is in place you can use the provided `package.sh` script to build the application image. Please note that this script is provided for example purposes only. You can provide it with the `rootfs` or `oci-img` argument in case you need a legacy (rootfs-based) or an OCI-based container image respectively.

Before continuing make sure you have followed the instructions to build the base toolchain image as described in the [README file](../README.md).

### Build a legacy rootfs image

To build a legacy rootfs tarball (image):

```shell
ARCH="armv7" ALPINE_PLATFORM="arm32v7" DOCKER_PLATFORM="linux/arm/v7" ./package.sh rootfs
ARCH="armv8" ALPINE_PLATFORM="arm64v8" DOCKER_PLATFORM="linux/arm64" ./package.sh rootfs
```

Check `dist/` directory for all the generated artifacts and container packages.

### Build an OCI image:

```shell
ARCH="armv7" ALPINE_PLATFORM="arm32v7" DOCKER_PLATFORM="linux/arm/v7" ./package.sh oci-img
ARCH="armv8" ALPINE_PLATFORM="arm64v8" DOCKER_PLATFORM="linux/arm64" ./package.sh oci-img
```

Since it is an OCI-image (located in your local docker cache) you can run it locally (with the help of qemu as described [here](../README.md#prerequisite)):

```shell
docker run --rm helloworld-armv7:1.0.0
docker run --rm helloworld-armv8:1.0.0
```

## VSCode DevContainers

The sample application includes the necessary files to support VSCode DevContainers out of the box. Please go through the relevant documentation to install and enable the DevContainers plugin. For more information refer [here](https://code.visualstudio.com/docs/devcontainers/containers).
