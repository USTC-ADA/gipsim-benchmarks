#!/bin/bash

arch=$1
benchclass=$2    # spec / parsec / npb
size=$3
scale=$4

# ========== Benchmark Definitions ==========

benchmark_choices=(spec parsec npb)

spec_workloads=(
    500.perlbench_r 502.gcc_r 503.bwaves_r 505.mcf_r 507.cactuBSSN_r 508.namd_r
    510.parest_r 511.povray_r 519.lbm_r 520.omnetpp_r 521.wrf_r 523.xalancbmk_r
    525.x264_r 526.blender_r 527.cam4_r 531.deepsjeng_r 538.imagick_r 541.leela_r
    544.nab_r 548.exchange2_r 549.fotonik3d_r 554.roms_r 557.xz_r
    600.perlbench_s 602.gcc_s 603.bwaves_s 605.mcf_s 607.cactuBSSN_s 619.lbm_s
    620.omnetpp_s 621.wrf_s 623.xalancbmk_s 625.x264_s 627.cam4_s 628.pop2_s
    631.deepsjeng_s 638.imagick_s 641.leela_s 644.nab_s 648.exchange2_s
    649.fotonik3d_s 654.roms_s 657.xz_s 996.specrand_fs 997.specrand_fr
    998.specrand_is 999.specrand_ir
)

parsec_workloads=(blackscholes bodytrack facesim ferret fluidanimate freqmine raytrace swaptions vips x264)
parsec_kernel_workloads=(canneal dedup streamcluster)

npb_workloads=(bt cg ep ft is lu mg sp)

spec_size=(test ref)
parsec_size=(test simdev simsmall simmedium simlarge native)
npb_size=(S A B C)

# ========== QEMU Launchers ==========

run_qemu_x86() {
    qemu-system-x86_64 \
      -m 8192 -smp 4 \
      -kernel ../disk-image/x86-disk-image-18-04/vmlinuz \
      -initrd ../disk-image/x86-disk-image-18-04/initrd.img \
      -append "root=/dev/vda1 rw console=ttyS0 init=/home/gipsim/init.sh -- $benchclass $1 $size $scale" \
      -drive file=../disk-image/x86-disk-image-18-04/x86-ubuntu,if=virtio,format=raw,snapshot=on \
      -nographic
}

run_qemu_arm() {
    qemu-system-aarch64 \
      -m 8192 -smp 4 \
      -machine virt \
      -cpu cortex-a57 \
      -kernel ../disk-image/arm-disk-image-18-04/vmlinuz \
      -initrd ../disk-image/arm-disk-image-18-04/initrd.img \
      -append "root=/dev/vda2 rw console=ttyAMA0 init=/home/gipsim/init.sh -- $benchclass $1 $size $scale" \
      -drive file=../disk-image/arm-disk-image-18-04/arm-ubuntu,if=virtio,format=raw,snapshot=on \
      -nographic
}

run_qemu_riscv() {
    qemu-system-riscv64 \
      -m 8192 -smp 4 \
      -machine virt \
      -bios /usr/lib/riscv64-linux-gnu/opensbi/generic/fw_jump.elf \
      -kernel ../disk-image/riscv-disk-image-22-04/vmlinuz \
      -initrd ../disk-image/riscv-disk-image-22-04/initrd.img \
      -append "root=/dev/vda1 rw console=ttyS0 init=/home/gipsim/init.sh -- $benchclass $1 $size $scale" \
      -drive file=../disk-image/riscv-disk-image-22-04/riscv-ubuntu,if=virtio,format=raw,snapshot=on \
      -nographic
}

run_arch() {
    case "$arch" in
        x86)   run_qemu_x86   "$1" ;;
        arm)   run_qemu_arm   "$1" ;;
        riscv) run_qemu_riscv "$1" ;;
        *)
            echo "[ERROR] Unsupported arch: $arch"
            exit 1;;
    esac
}

# ========== Select Workload List ==========

case "$benchclass" in
    spec)
        if [[ ! " ${spec_size[*]} " =~ " $size " ]]; then
            echo "[ERROR] Invalid SPEC size: $size"
            exit 1
        fi
        workloads=("${spec_workloads[@]}")
        ;;
    parsec)
        if [[ ! " ${parsec_size[*]} " =~ " $size " ]]; then
            echo "[ERROR] Invalid Parsec size: $size"
            exit 1
        fi
        workloads=("${parsec_workloads[@]}" "${parsec_kernel_workloads[@]}")
        ;;
    npb)
        if [[ ! " ${npb_size[*]} " =~ " $size " ]]; then
            echo "[ERROR] Invalid NPB size: $size"
            exit 1
        fi
        workloads=("${npb_workloads[@]}")
        ;;
    *)
        echo "[ERROR] Invalid benchclass: $benchclass"
        exit 1;;
esac

# ========== Main Loop ==========

mkdir -p logs/${arch}/${benchclass}/

for bench in "${workloads[@]}"; do
    logfile="${bench}-${size}-${scale}.ansi"
    echo "[INFO] Running $arch $benchclass $bench size=$size scale=$scale"
    run_arch "$bench" > "logs/${arch}/${benchclass}/$logfile" 2>&1
done
