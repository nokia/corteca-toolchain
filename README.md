# Base image for Corteca Toolchain

Part of Corteca Developer Toolkit, Toolchain is a set of compilation tools that help isolate the application within the container, avoiding interaction with the host system's libraries in the creation of applications for [Corteca Marketplace](https://www.nokia.com/networks/fixed-networks/corteca-applications/). This repository is hosted on [https://github.com/nokia/corteca-toolchain](https://github.com/nokia/corteca-toolchain)

## Clone the repository

### Clone with submodules

```bash
git clone --recurse-submodules https://github.com/nokia/corteca-toolchain.git
```

### Add submodules after cloning

In case you have previously cloned the repository without `--recurse-submodules` you can do:

```bash
git submodule update --init --recursive
```

## Repo layout

```shell
├── Documentation       # Documentation
├──.VERSION             # Toolchain image version
├── Jenkinsfile         # Pipeline
├── README.md           # This file
└── Dockerfile          # Toolchain image Dockerfile
```

## Build toolchain

### Prerequisites

The toolchain image is a multi-platform image, this means that a single image is created and depending on the running platform docker only pulls the layers for the specific architecture.
To enable multi-platform image build we need to change the storage driver and enable docker to run images for different CPU architectures.

#### Storage drivers

In order to be able to build multi-platform images you need to change the storage driver of docker. The easiest way to do it is to use the [`containerd image store`](https://docs.docker.com/storage/containerd/)

create file `/etc/docker/daemon.json` with the following contents and restart docker daemon

```text
{
  "features": {
    "containerd-snapshotter": true
  }
}
```

#### Execution of different multi-architecture

Since we build the image for multiple platforms we need to support the execution of different platforms, we also need that in order to run arm64 containers on intel/amd 64bit CPUs.

For this we need enable execution of different multi-architecture containers by QEMU and binfmt_misc. For more information, see [qemu-user-static](https://github.com/multiarch/qemu-user-static).

```shell
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

### Build a multi-platform base image

Currently we build an image for amd64, arm32 and arm64.

```shell
docker buildx build \
    --platform linux/amd64,linux/arm64,linux/arm/v7 \
    -t ghcr.io/nokia/corteca-toolchain:$(cat .VERSION) \
    -t ghcr.io/nokia/corteca-toolchain \
    - < Dockerfile
```

### Test the images

We can test that our image supports multiple platforms and test each one of those

#### Arm v8 (64bits)

```shell
docker run --rm -it --platform linux/arm64 ghcr.io/nokia/corteca-toolchain uname -m
```

expected output:

```text
aarch64
```

#### Arm v7 (32bits)

```shell
docker run --rm -it --platform linux/arm/v7 ghcr.io/nokia/corteca-toolchain uname -m
```

expected output:

```text
armv7l
```

#### Amd64 (64bits)

```shell
docker run --rm -it --platform linux/amd64 ghcr.io/nokia/corteca-toolchain uname -m
```

expected output:

```text
x86_64
```

### Run a container

You can create a running container e.g. for arm64:

```shell
docker run --rm -it --platform linux/arm64 ghcr.io/nokia/corteca-toolchain
```
