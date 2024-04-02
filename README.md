---
title: Corteca Toolchain v23.12.1
---

Part of Corteca Developer Toolkit, Toolchain is a set of compilation tools that help isolate the application within the container, avoiding interaction with the host system's libraries in the creation of applications for [Corteca Marketplace](https://www.nokia.com/networks/fixed-networks/corteca-applications/). This repository is hosted on [https://github.com/nokia/corteca-toolchain](https://github.com/nokia/corteca-toolchain)

## Repo layout

```text
├── context -> Toolchain image context (files to be included in the images)
│   ├── config -> Buildroot configuration files for each toolchain
│   ├── environments -> Environment variables for each toolchain
│   └── scripts
│       └── nokia_toolchain.sh -> Script for invoking toolchain actions inside the container
├── images -> Image resources for this file
├── sample-application -> Sample Container Application
├── Dockerfile -> Toolchain image Dockerfile
└── README.md -> this file
└── USAGE.md -> Corteca Development Platform Documentation
```

## Introduction

This repository contains the files needed to build the Corteca Toolchains.

## Prerequisites

In order to be able to build your application you need to have docker installed and create a directory structure to hold the source code and all the other files that are need for your application.

### Docker

The toolchains for compiling and building the containers require docker or a compatible container engine. This document assumes that you use docker. Make sure you have docker installed.

```shell
docker --version
```

If this fails, please follow the installation procedure for your OS.

### Sample application

In order to be able to build your application you need to create a directory structure to hold the source code and all the other files that are need for the container package creation. For more information on those, you can take a look at the [Sample Container Application Documentation](./sample-application/README.md).
