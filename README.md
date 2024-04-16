# Corteca Toolchain v23.12.1

Part of Corteca Developer Toolkit, Toolchain is a set of compilation tools that help isolate the application within the container, avoiding interaction with the host system's libraries in the creation of applications for [Corteca Marketplace](https://www.nokia.com/networks/fixed-networks/corteca-applications/). This repository is hosted on [https://github.com/nokia/corteca-toolchain](https://github.com/nokia/corteca-toolchain)

## Repo layout

```shell
├── context                     # Toolchain image context (files to be included in the images)
│   ├── config                  # Buildroot configuration files for each toolchain
│   ├── environments            # Environment variables for each toolchain
│   └── scripts
│       └── nokia_toolchain.sh  # Script for invoking toolchain actions inside the container
├── images                      # Image resources for this file
├── sample-application          # Sample Container Application
├── Dockerfile                  # Toolchain image Dockerfile
├── README.md                   # this file
└── USAGE.md                    # Corteca Development Platform Documentation
```

## Introduction

This repository contains the files needed to build the Corteca Toolchains. There are 2 flavors of the toolchain depending on the target CPU architecture:

| Toolchain name          | CPU Architecture        | Indicative list of Corteca devices |
| ----------              | ----------------------- | ------------ |
| `corteca-toolchain-armv7` | armv7, arm-el, 32-bits  | Beacon 6 |
| `corteca-toolchain-armv8` | armv8, aarch64, 64-bits | Beacon 10, Beacon 24, Beacon G6, XS-2426X-A, XS-2426G-B, Beacon3.1 / G-1426G-A |

Both of the images are based on Buildroot v2023.02.1 and are configured for each CPU architecture. The following packages are installed by default in the target filesystem:

- Linux Kernel Headers v4.14.x
- binutils v2.37
- libc: musl v1.2.3
- gcc v10
- ubus
- mbedTLS

## Prerequisites

In order to be able to build your application you need to have docker installed and create a directory structure to hold the source code and all the other files that are need for your application.

### Docker

The toolchains for compiling and building the containers require docker or a compatible container engine. This document assumes that you use docker. Make sure you have docker installed.

```shell
docker --version
```

If this fails, please follow the installation procedure for your OS.

### Sample application

In order to be able to build your application you need to create a specific directory structure to hold the source code and all the other files that are need for the container package creation. For more information on this, you can take a look at the [Sample Container Application Documentation](sample-application/README.md).

For instructions on using the toolchain to build your application, refer to [Corteca Development Platform Documentation](USAGE.md)
