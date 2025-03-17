#!/bin/bash
# Based on: https://github.com/GoogleCloudPlatform/nfs-server-docker/blob/master/1/debian11/1.3/docker-entrypoint.sh

set -e

function start()
{
    # --- Use Environment Variables ---
    SHARED_DIRECTORY="${SHARED_DIRECTORY:-/nfs-server}"
    ALLOWED_CLIENT="${ALLOWED_CLIENT:-}"
    NFS_OPTIONS="${NFS_OPTIONS:-rw,sync,no_subtree_check,no_root_squash,fsid=0}"

    if [ -z "$ALLOWED_CLIENT" ]; then
        echo "Error: ALLOWED_CLIENT environment variable must be set." >&2
        exit 1
    fi

    # prepare /etc/exports
    echo "$SHARED_DIRECTORY $ALLOWED_CLIENT($NFS_OPTIONS)" > /etc/exports

    echo "Serving $SHARED_DIRECTORY"

    # start rpcbind if it is not started yet
    /usr/sbin/rpcinfo 127.0.0.1 > /dev/null; s=$?
    if [ $s -ne 0 ]; then
       echo "Starting rpcbind"
       /sbin/rpcbind -w
    fi

    mount -t nfsd nfds /proc/fs/nfsd

    # -V 3: enable NFSv3
    /usr/sbin/rpc.mountd -N 2 -V 3

    /usr/sbin/exportfs -r
    # -G 10 to reduce grace time to 10 seconds (the lowest allowed)
    /usr/sbin/rpc.nfsd -G 10 -N 2 -V 3
    /sbin/rpc.statd --no-notify
    echo "NFS started"
}

function stop()
{
    echo "Stopping NFS"

    /usr/sbin/rpc.nfsd 0
    /usr/sbin/exportfs -au
    /usr/sbin/exportfs -f

    kill "$(pidof rpc.mountd)"
    umount /proc/fs/nfsd
    echo > /etc/exports
    exit 0
}

trap stop TERM

start "$@"

# Ugly hack to do nothing and wait for SIGTERM
while true; do
    sleep 5
done
