#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run as root."
  exit 1
fi

echo "Optimizing memory: Removing swap and disabling paging..."

swapoff -a || true

if [ -f /etc/fstab ]; then
    sed -i.bak -E '/\sswap\s/d' /etc/fstab
    sed -i -E '/\bfloppy\b/d' /etc/fstab
    echo "Removed swap and floppy entries from /etc/fstab."
fi
