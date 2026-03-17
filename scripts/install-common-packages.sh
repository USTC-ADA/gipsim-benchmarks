#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run as root."
  exit 1
fi

ARCH=${ISA:-$(uname -m)}
case "$ARCH" in
    x86_64|x86) ISA_NAME="x86" ;;
    arm*|aarch64) ISA_NAME="arm64" ;;
    riscv*) ISA_NAME="riscv" ;;
    *) echo "Unsupported ISA: $ARCH"; exit 1 ;;
esac

set -e

setup_serial_console() {
    echo "Configuring serial console autologin..."
    local OVERRIDE_DIR="/etc/systemd/system/serial-getty@.service.d"
    local OVERRIDE_CONF="/home/gipsim/serial-getty@.service-override.conf"

    mkdir -p "$OVERRIDE_DIR"
    if [ -f "$OVERRIDE_CONF" ]; then
        mv "$OVERRIDE_CONF" "$OVERRIDE_DIR/override.conf"
    else
        cat <<EOF > "$OVERRIDE_DIR/override.conf"
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --keep-baud 115200,38400,9600 %I \$TERM
EOF
    fi
    echo "Serial console configured."
}

install_dependencies() {
    echo "Installing common packages..."
    export DEBIAN_FRONTEND=noninteractive
    
    echo "* libraries/restart-without-asking boolean true" | debconf-set-selections

    apt-get update
    apt-get install -y --no-install-recommends \
        scons git vim build-essential gfortran ca-certificates

    rm -rf /etc/update-motd.d/*
    echo "Package installation done."
}

build_m5_utility() {
    echo "Building m5 utility for $ISA_NAME..."
    local WORK_DIR="/tmp/gem5_build"
    mkdir -p "$WORK_DIR"
    cd "$WORK_DIR"

    git clone https://gh-proxy.org/https://github.com/gem5/gem5.git --depth=1 --single-branch --branch=stable

    pushd gem5
    cp -r include/gem5 /usr/local/include/
    
    pushd util/m5
    if [ "$ISA_NAME" == "riscv" ]; then
        scons riscv.CROSS_COMPILE='' build/riscv/out/m5
    else
        scons build/${ISA_NAME}/out/m5
    fi

    cp build/${ISA_NAME}/out/m5 /usr/local/bin/gem5-bridge
    cp build/${ISA_NAME}/out/libm5.a /usr/local/lib/
    popd
    popd

    chmod 4755 /usr/local/bin/gem5-bridge
    ln -sf /usr/local/bin/gem5-bridge /usr/local/bin/m5

    rm -rf "$WORK_DIR"
    echo "m5 utility installed successfully."
}

setup_runscript() {
    echo "Configuring automatic runscript on login..."
    
    local RUN_CMD="bash /home/gipsim/runscript.sh"
    
    if ! grep -q "$RUN_CMD" /root/.bashrc; then
        echo "$RUN_CMD" >> /root/.bashrc
    fi

    if [ -f "/home/gipsim/init.sh" ]; then
        chmod +x /home/gipsim/init.sh
    fi
}

setup_serial_console
install_dependencies
build_m5_utility
setup_runscript

echo "All environment setup tasks completed!"