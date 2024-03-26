---
title: Corteca Toolchain v23.12.1
---

## Repo layout

```text
├── context -> Toolchain image context (files to be included in the images)
│   ├── config -> Buildroot configuration files for each toolchain
│   ├── environments -> Environment variables for each toolchain
│   └── scripts
│       └── nokia_toolchain.sh -> Script for invoking toolchain actions inside the container
├── images -> Image resources for this file
├── Dockerfile -> Toolchain image Dockerfile
└── README.md -> this file
```

## Introduction

This guide contains step-by-step instructions on how to generate a containerized application package for the Corteca ecosystem.

## Prerequisites

In order to be able to build your application you need to create a directory structure to hold the source code and all the other files that are need for the container package creation.

### Docker

The toolchains for compiling and building the containers require docker or a compatible container engine. This document assumes that you use docker. Make sure you have docker installed.

```bash
docker --version
```

If this fails, please follow the installation procedure for your OS.

### Corteca Toolchains

You need to have the Corteca Toolchain images. This are published in Docker Hub.

```shell
docker pull nokia/corteca-toolchain-arv7:23.12.1
docker pull nokia/corteca-toolchain-arv8:23.12.1
```

### Containerized Application Workflow

![Workflow](images/workflow.png)
