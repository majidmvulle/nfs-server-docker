FROM debian:12

ARG NFS_VERSION=1:2.6.2-4+deb12u1

RUN set -x && \
    apt update && apt install -y -qq openssl rpcbind nfs-common nfs-kernel-server=${NFS_VERSION}* && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /nfs-server

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +rx /usr/local/bin/docker-entrypoint.sh

VOLUME /nfs-server

EXPOSE 2049/tcp
EXPOSE 20048/tcp

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s \
  CMD exportfs -v || exit 1

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
