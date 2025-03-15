#!/bin/bash
set -e

# --- Configuration via Environment Variables ---

# Shared directory (optional, with defaults).
SHARED_DIRECTORY="${SHARED_DIRECTORY:-/exports}"

# Client network/IP/Hostname (REQUIRED).
ALLOWED_CLIENT="${ALLOWED_CLIENT:-}"

# NFS Options (optional, with defaults).
NFS_OPTIONS="${NFS_OPTIONS:-rw,sync,no_subtree_check,no_root_squash}"

# --- Helper Functions ---

log() {
  echo "[nfs-server] $@"
}

# --- Setup Exports ---

log "Configuring NFS exports..."

# Check if ALLOWED_CLIENT is set.  This is now REQUIRED.
if [ -z "$ALLOWED_CLIENT" ]; then
  log "Error: ALLOWED_CLIENT environment variable must be set."
  exit 1
fi

# Create the /etc/exports file dynamically.
cat > /etc/exports <<EOF
$SHARED_DIRECTORY $ALLOWED_CLIENT($NFS_OPTIONS)
EOF

# Validate exports
if ! exportfs -a; then
    log "Error: Invalid exports configuration. Check your SHARED_DIRECTORY, ALLOWED_CLIENT, and NFS_OPTIONS."
    exit 1
fi

# --- Start Services ---

log "Starting rpcbind..."
/usr/sbin/rpcbind -w

log "Starting nfs-kernel-server..."
exec /etc/init.d/nfs-kernel-server start
