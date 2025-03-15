# nfs-server-docker

[![Build Status](https://github.com/majidmvulle/nfs-server-docker/actions/workflows/002-build-and-push-gcr.yaml/badge.svg)](https://github.com/majidmvulle/nfs-server-docker/actions/workflows/002-build-and-push-gcr.yaml)

A simple Docker image for running an NFS server.  This image is based on Debian 12 and uses `nfs-kernel-server`.

## Features

*   Easy to set up and configure.
*   Exports a directory (`/exports` by default) via NFS.
*   Uses `rpcbind` and `nfs-kernel-server`.
*   Healthcheck included to verify NFS server status.

## Usage

### Basic Usage

```shell
docker run --name nfs-server \
    -v /path/to/your/data:/exports \
    -p 2049:2049 -p 20048:20048 \
    --cap-add SYS_ADMIN \
    nfs-server-docker
```

### Docker Compose
```shell
version: "3.7"
services:
  nfs-server:
    image: ghcr.io/majidmvulle/nfs-server-docker
    volumes:
      - /path/to/your/data:/exports
    ports:
      - "2049:2049"
      - "20048:20048"
    cap_add:
      - SYS_ADMIN
    restart: unless-stopped
```

### Building the Image Locally
```shell
docker build -t nfs-server-docker .
```

## Environment Variables
* No custom environment variables are currently implemented, the default configuration is used, however, you could use a custom nfs version at build stage `--build-arg NFS_VERSION=1:2.6.2-4+deb12u1`, only nfs v4+ is supported.

## Configuration
The NFS server is configured using the standard `/etc/exports` file. Because you mount your data directory to `/exports` inside the container, the simplest way to configure exports is to create an exports file within your data directory on the host.

**Example /path/to/your/data/exports file:**
```shell
/exports        10.0.0.0/24(rw,sync,no_subtree_check)
/exports/subdir  10.0.0.10(rw,sync,no_subtree_check)
```
* `/exports:` The root directory being exported. 
* `10.0.0.0/24:` The allowed client network CIDR range. 
* `rw:` Read/write access. 
* `sync:` Synchronous writes (recommended for data integrity). 
* `no_subtree_check:` Disables subtree checking (often improves performance, but can have security implications in some cases). 
* `/exports/subdir 10.0.0.10:` Example of exporting a subdirectory to a specific client IP address.

**Note:** Make sure the permissions on your host directory (`/path/to/your/data`) and any subdirectories are set correctly for your NFS clients. You might need to adjust ownership and permissions using `chown` and `chmod`.

## License
This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
