#!/bin/bash
echo "Installing serial service override for autologin after systemd."

mkdir /etc/systemd/system/serial-getty@.service.d/
mv /home/gipsim/serial-getty@.service-override.conf /etc/systemd/system/serial-getty@.service.d/override.conf

systemctl disable boot-efi.mount
systemctl mask boot-efi.mount
systemctl disable cloud-init.target
systemctl mask cloud-init.target

systemctl daemon-reload

echo "Installation of serial service override done."

echo "Installing common packages."

echo "* libraries/restart-without-asking boolean true" | sudo debconf-set-selections

echo "12345" | sudo apt-get update
echo "12345" | sudo apt-get install -y scons git vim build-essential gfortran

# Remove the motd
rm /etc/update-motd.d/*

echo "Building and installing gem5-bridge (m5) and libm5"

if [ -z "$ISA" ]; then
  echo "Error: ISA environment variable is not set."
  exit 1
fi

cd /home/gipsim/
git clone https://github.com/gem5/gem5.git --depth=1 --single-branch --branch=stable

pushd gem5
cp -r include/gem5 /usr/local/include/
pushd util/m5
if [ "$ISA" == "riscv" ]; then
    scons riscv.CROSS_COMPILE='' build/riscv/out/m5
else
    scons build/${ISA}/out/m5
fi
cp build/${ISA}/out/m5 /usr/local/bin/
cp build/${ISA}/out/libm5.a /usr/local/lib/
popd
popd

mv /usr/local/bin/m5 /usr/local/bin/gem5-bridge
chmod 4755 /usr/local/bin/gem5-bridge
chmod u+s /usr/local/bin/gem5-bridge
ln -s /usr/local/bin/gem5-bridge /usr/local/bin/m5
rm -rf gem5

echo "Done building and installing gem5-bridge (m5) and libm5"

echo "bash /home/gipsim/runscript.sh" >> /root/.bashrc
echo "12345" | sudo chmod +x /home/gipsim/init.sh

echo "Installation of common packages done."
