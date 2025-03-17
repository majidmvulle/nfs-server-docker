#!/bin/bash
set -e

# --- Configuration via Environment Variables ---

SHARED_DIRECTORY="${SHARED_DIRECTORY:-/nfs-server}"
ALLOWED_CLIENT="${ALLOWED_CLIENT:-}"
NFS_OPTIONS="${NFS_OPTIONS:-rw,sync,no_subtree_check,no_root_squash,fsid=0}"

# --- Helper Functions ---

log() {
  echo "[nfs-server] $@"
}

# --- Setup Exports ---

log "Configuring NFS exports..."

if [ -z "$ALLOWED_CLIENT" ]; then
  log "Error: ALLOWED_CLIENT environment variable must be set."
  exit 1
fi

cat > /etc/exports <<EOF
$SHARED_DIRECTORY $ALLOWED_CLIENT($NFS_OPTIONS)
EOF

# Validate exports.  Do this *before* starting services.
if ! exportfs -a; then
    log "Error: Invalid exports configuration.  Check your SHARED_DIRECTORY, ALLOWED_CLIENT, and NFS_OPTIONS."
    exit 1
fi

# --- Start Services ---

log "Starting rpcbind..."
/sbin/rpcbind -w # Start rpcbind, wait for it to initialize

log "Starting NFS services..."
mount -t nfsd nfds /proc/fs/nfsd  # Keep this - it's necessary
/usr/sbin/rpc.mountd
/usr/sbin/rpc.nfsd
/sbin/rpc.statd --no-notify
/usr/sbin/exportfs -r

log "NFS started"

# Keep the container running
while true; do
    sleep 3600
done
