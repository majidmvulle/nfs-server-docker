#!/bin/bash
set -e

configure_exports() {
  echo "[nfs-server] Configuring NFS exports..."
  if [ ! -f /etc/exports ]; then
    touch /etc/exports
  fi

  if [ -f "/exports/exports" ]; then
    echo "[nfs-server] Using custom exports file from /exports/exports"
    cat /exports/exports > /etc/exports
  else
    echo "[nfs-server] Using default exports (exporting /exports to all)"
    echo "/exports *(rw,sync,no_subtree_check,no_root_squash)" > /etc/exports
  fi

  exportfs -ra
}

start_services() {
  echo "[nfs-server] Starting rpcbind..."
  /usr/sbin/rpcbind -w

  echo "[nfs-server] Starting nfs-kernel-server..."
  if command -v systemctl &> /dev/null; then
    systemctl start nfs-kernel-server
    systemctl enable nfs-kernel-server
  elif command -v service &> /dev/null; then
    service nfs-kernel-server start
  else
    echo "No init system detected"
    exit 1
  fi

  # Keep the container running
  tail -f /dev/null
}

configure_exports "$@"
start_services
