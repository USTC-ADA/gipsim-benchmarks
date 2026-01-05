#!/bin/bash
echo "Installing SPEC CPU 2017 benchmark for riscv64."

tar -xzvf /home/gipsim/spec/CPU-2017.tar.gz -C /home/gipsim/spec

cd /home/gipsim/spec/CPU-2017
./install.sh -u linux-riscv64 -f
source shrc

rm -f /home/gipsim/spec/CPU-2017.tar.gz

cp /home/gipsim/spec/CPU-2017/config/Example-gcc-linux-riscv64.cfg /home/gipsim/spec/CPU-2017/config/myconfig.riscv64.cfg

sed -i "s/command_add_redirect = 1/sysinfo_program =\ncommand_add_redirect = 1/g" /home/gipsim/spec/CPU-2017/config/myconfig.riscv64.cfg

runcpu --config myconfig.riscv64.cfg --define build_ncpus=$(nproc) --define gcc_dir="/usr" --action build all
runcpu --size test --iterations 1 --config myconfig.riscv64.cfg --define gcc_dir="/usr" --noreportable --nobuild --action runsetup all
runcpu --size ref --iterations 1 --config myconfig.riscv64.cfg --define gcc_dir="/usr" --noreportable --nobuild --action runsetup all

rm -f /home/gipsim/spec/CPU-2017/result/*
