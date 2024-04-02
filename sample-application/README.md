---
title: Sample Container Application v23.12.1
---

This is a sample hello world application used to demonstrate the Corteca tooolchain functionality

## Directory structure

For your container application, the following structure shows the recommended layout.

| name | Description |
| ---- | ----------- |
| .devcontainer/ | The directory with the VSCode DevContainer plugin configuration files for the toolchains |
| build/ | Directory for the compiled/generated artifacts. Files that will be create by make will end up in here |
| dist/ | Directory for the generated compressed container application artifacts. |
| src/ | Directory with the source code of the application |
| target/ | Directory for files that we need to copy `as is` to the container (e.g: configuration files, precompiled binaries, etc. reside in here) |
| tests/ | Functional and product testing scripts |
| ADF | Application Description File (json file), used to describe the content in the tarball and the application runtime environment requirements |
| Makefile | The main makefile that is used to invoke the scripts needed to build the app. In gerneral it will invoke the `Makefile` in `src/` directory |
| README.md | Readme of the application (this file) |

In your host you must have a directory that includes the ADF file of your application and a directory named `src/` with the source code of your application. Inside `src/` you must have a Makefile that can compile your application.

### build/

Compiled/generated artifacts will be created in here.

| name | Description |
| ---- | ----------- |
| build/`ARCH`/app | For each architecture there is a directory structure with the compiled binaries/libraries. This directory is copied recursively to the target rootfs |
| build/`ARCH`/pkg | Directory with all the files of the application package |
| build/`ARCH`/pkg/ADF | `ADF` file to be included in the application package (automatically copied here)|
| build/`ARCH`/pkg/rootfs.tar.gz | Compressed contents of `build/ARCH/rootfs/` |
| build/`ARCH`/rootfs/ | Extracted rootfs directory. All compiled/generated files and the files from `target/`, are copied here before genertating `build/ARCH/pkg/rootfs.tar.gz` |

### dist/

Compressed package of the containerized application for each architecture will be created in here. These files can be used to install the application in a device.

| name | Description |
| ---- | ----------- |
| dist/`APP`-`VERSION`-`ARCH`-rootfs.tar.gz | The complete container application package file for each architecture|

### src/

For a container application you need to have the source code of your application in folder `src/`

| name | Description |
| ---- | ----------- |
| src/helloworld.c | Source code file |
| . | all |
| . | other |
| . | files |
| src/Makefile | The source code makefile, used to compile/build the application |

If you don't use make for your application, then you need to adjust the main `Makefile` and set the `build` target accordingly.

### target/

Directory for files that we need to copy `as is` to the container (e.g: configuration files, precompiled binaries, etc. reside in here).

| name | Description |
| ---- | ----------- |
| target/noarch/ | Directory for architecture agnostic files (e.g.: configuration files, scripts, static files, images/logos, etc). |
| target/`ARCH`/ | Directory with precompiled or other files that are architecture specific. (e.g.: precompiled libraries, binaries, etc ) |

### tests/

Functional and product testing scripts

| name | Description |
| ---- | ----------- |
| tests/functional/         | Directory with all the files and scripts needed for functional testing of the application |
| tests/functional/tests.sh | Script that runs all functional tests |
| tests/product/            | Directory with all the files and scripts needed for product testing of the application |
| tests/product/tests.sh    | Script that runs all product tests |

### Makefile

Your makefile must have a default target that builds your application. By default it expects to have a makefile under `src/` which is invoked. If your application uses a different method for compilation and build, make sure to adjust your build target to invoke the necessary scripts.

### ADF

Application Description File (json file), used to describe the content in the tarball and the application runtime environment requirements.

#### ADF description and fields explanation

```jsonc
{
  "annotations": {                          // REQUIRED
    "com.nokia.app_name": "helloworld",     // REQUIRED (string) - data model: SoftwareModules.DeploymentUnit.{i}.Name and SoftwareModules.ExecutionUnit.{i}.Name
    "com.nokia.embedded_rootfs": true,      // REQUIRED (bool)
    "com.nokia.app_version": "1.2.0",       // REQUIRED (string) - data model: SoftwareModules.DeploymentUnit.{i}.Version
    "com.nokia.unprivileged": false,        // OPTIONAL (bool)  - Unprivileged containers are not supported in current version
    "com.nokia.embedded_package": {         // REQUIRED
      "name": "rootfs.tar.gz",              // REQUIRED (string)
      "type": "tar"                         // REQUIRED (string) [tar, ipk]
    },
    "com.nokia.app_stop_timeout": "15",     // OPTIONAL (string [1 - 20]
  },
  "hostname": "HelloWorld",                 // OPTIONAL (string) - default is an empty string
  "config": {                               // REQUIRED
    "Env": [                                // OPTIONAL (Array of strings)
      "PATH=/usr/local/sbin:/usr/local/bin",
      "LD_LIBRARY_PATH=/usr/lib"
    ]
    "Cmd": [                                // REQUIRED (Array of strings with length 1)
      "/bin/helloworld"
    ]
  },
  "linux": {                                // OPTIONAL - Specifies Linux container configuration
    "resources": {                          // OPTIONAL - Specifies resource limitation of the container
      "memory": {                           // OPTIONAL - set limits on the container's memory usage
        "limit": "10M"                      // OPTIONAL - Sets limit of memory usage. The default is 10M
      },
      "cpu": {                              // OPTIONAL - Represents the cgroup subsystems cpu and cpusets.
        "quota": "4",                       // OPTIONAL - Specifies the total amount of time in microseconds for which all tasks in a cgroup can run during one period (as defined by the period below). The default is "5"
        "period": "100"                     // OPTIONAL - Specifies a period in microseconds for how regularly a cgroup's access to CPU resources should be reallocated (CFS scheduler only). The default is "100".
      }
    }
  }
  "mounts": [{                              // OPTIONAL (Array)
      "destination": "/opt",                // REQUIRED (string)
      "source": "/var/run/ubus-session",    // REQUIRED (string)
      "options": [                          // OPTIONAL (Array)
        "rbind",
        "rw"
      ]
  }],
  "hooks":{                                 // OPTIONAL - Specifies the container's hooks which will be invoked by the host
    "prestart":[{                           // OPTIONAL - Specifies the hooks which will be invoked by the host before starting the container
      "path": "/bin/prepare_container.sh"   // OPTIONAL - Specifies the path of hook. The default is empty string
    }],
    "poststop":[{                           // OPTIONAL - pecifies the hooks which will be invoked by the host after stopping the container
      "path": "/bin/cleanup_container.sh"   // OPTIONAL - Specifies the path of hook. The default is empty string
    }]
  }
  "network": {
    "type": "share"
  }
}
```

#### Sample ADF file

```json
{
  "annotations": {
    "com.nokia.app_name": "helloworld",
    "com.nokia.embedded_rootfs": true,
    "com.nokia.app_version": "1.2.0",
    "com.nokia.unprivileged": false,
    "com.nokia.embedded_package": {
      "name": "rootfs.tar.gz",
      "type": "tar"
    },
    "com.nokia.app_stop_timeout": "10",
  },
  "hostname": "HelloWorld",
  "config": {
    "Env": ["VARIABLE=VALUE"],
    "Cmd": ["/bin/helloworld"]
  },
  "linux": {
    "resources": {
      "memory": {
        "limit": "15M"
      },
      "cpu": {
        "quota": "4",
        "period": "100"
      }
    }
  }
  "mounts": [{
      "destination": "/opt",
      "source": "/var/run/ubus-session",
      "options": ["rbind", "rw"]
  }],
  "hooks":{
    "prestart":[{"path": "/bin/prepare_container.sh"}],
    "poststop":[{"path": "/bin/cleanup_container.sh"}]
  }
  "network": {
    "type": "share"
  }
}
```

## Building the container

If everything is in place you can use the corteca toolchain images to build your application. For our examples we will use version `23.12.1` for `armv8`.

### Generating Container Artifact

```shell
docker run -u "$(id -u):$(id -g)" -v ./:/app corteca-toolchain-armv8:23.12.1
```

Check `/app/build/` directory for all the generated artifacts and `/app/dist/` for the container packages.

### Cleaning up

All artifacts generated under `/app/dist/` and `/app/build/` are ignored by git, but you can always clean them up by running the following command

```shell
docker run -u "$(id -u):$(id -g)" -w /app -v ./:/app corteca-toolchain-armv8:23.12.1 nokia_toolchain distclean"
```

## VSCode DevContainers

The sample application includes the necessary files to support VSCode DevContainers out of the box. Please go through the relevant documentation to install and enable the DevContainers plugin. [Developing inside a Container](https://code.visualstudio.com/docs/devcontainers/containers)
