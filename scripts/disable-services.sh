#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

ARCH=${ISA:-$(uname -m)}
echo "Optimizing for architecture: $ARCH"

SERVICES_TO_DISABLE=(
    multipathd.service
    thermald.service
    accounts-daemon.service
    lvm2-monitor.service
    udisks2.service
    rsyslog.service
    irqbalance.service
    unattended-upgrades.service
    whoopsie.service
    apport.service
    polkit.service
    cloud-init.service
    cloud-config.service
    cloud-final.service
    cloud-init-local.service
)

SERVICES_TO_MASK=(
    systemd-random-seed.service 
    ModemManager.service
    networkd-dispatcher.service
    systemd-networkd-wait-online.service
    NetworkManager-wait-online.service
    systemd-networkd.service
    systemd-timesyncd.service
    apt-daily.timer
    apt-daily-upgrade.timer
    fstrim.timer
    man-db.timer
    plymouth-start.service
    plymouth-quit.service
    plymouth-read-write.service
)

echo "Disabling services..."
for svc in "${SERVICES_TO_DISABLE[@]}"; do
    systemctl disable "$svc" >/dev/null 2>&1
done

echo "Masking critical services..."
for svc in "${SERVICES_TO_MASK[@]}"; do
    systemctl mask "$svc" >/dev/null 2>&1
done

if systemctl list-unit-files | grep -q snapd; then
    systemctl disable snapd.service snapd.socket snapd.apparmor.service
fi

systemctl disable apparmor.service
systemctl set-default multi-user.target

echo "Applying gem5 specific tweaks..."

mkdir -p /etc/systemd/journald.conf.d/
cat <<EOF > /etc/systemd/journald.conf.d/99-gem5.conf
[Journal]
Storage=none
EOF

sed -i 's/#DefaultTimeoutStartSec=90s/DefaultTimeoutStartSec=10s/' /etc/systemd/system.conf
sed -i 's/#DefaultTimeoutStopSec=90s/DefaultTimeoutStopSec=10s/' /etc/systemd/system.conf

case "$ARCH" in
    x86*|i386)
        echo "Additional x86 tweaks..."
        ;;
    arm*|aarch64)
        echo "Additional ARM tweaks..."
        ;;
    riscv*)
        echo "Additional RISC-V tweaks..."
        systemctl mask serial-getty@hvc0.service
        ;;
esac

echo "Done. Reboot the guest to see the effects."