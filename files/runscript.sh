#!/bin/bash

raw_arch=$(uname -m)
case "$raw_arch" in
    x86_64)
        arch="x86"
        ;;
    aarch64)
        arch="arm"
        ;;
    riscv64)
        arch="riscv"
        ;;
    *)
        echo "[ERROR] Unsupported architecture: $raw_arch"
        exit 1
        ;;
esac

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

# ========== Read Workload File ==========

echo "Reading Benchmark selection ..."
read -r benchmark workload size scale < /workloadfile

echo "Raw Input => $benchmark $workload $size $scale"
echo

# ========== Validation Functions ==========

contains() {
    local item=$1; shift
    for x in "$@"; do [[ "$x" == "$item" ]] && return 0; done
    return 1
}

# ========== Validate Benchmark ==========

if ! contains "$benchmark" "${benchmark_choices[@]}"; then
    echo "[ERROR] Invalid benchmark type: $benchmark"
    echo "Valid options: ${benchmark_choices[*]}"
    exit 1
fi

# ========== Validate Workload ==========

case "$benchmark" in
    spec)
        if ! contains "$workload" "${spec_workloads[@]}"; then
            echo "[ERROR] Invalid SPEC workload: $workload"
            exit 1
        fi
        valid_sizes=("${spec_size[@]}")
        ;;
    parsec)
        if contains "$workload" "${parsec_workloads[@]}"; then
            base_dir="/home/gipsim/parsec/parsec-benchmark/pkgs/apps/$workload"
        elif contains "$workload" "${parsec_kernel_workloads[@]}"; then
            base_dir="/home/gipsim/parsec/parsec-benchmark/pkgs/kernels/$workload"
        else
            echo "[ERROR] Invalid PARSEC workload: $workload"
            exit 1
        fi
        valid_sizes=("${parsec_size[@]}")
        ;;
    npb)
        if ! contains "$workload" "${npb_workloads[@]}"; then
            echo "[ERROR] Invalid NPB workload: $workload"
            exit 1
        fi
        valid_sizes=("${npb_size[@]}")
        ;;
esac

# ========== Validate Size ==========

if ! contains "$size" "${valid_sizes[@]}"; then
    echo "[ERROR] Invalid size '$size' for benchmark '$benchmark'"
    echo "[INFO] Valid sizes: ${valid_sizes[*]}"
    exit 1
fi

# ========== Final Output ==========

echo "=============================="
echo "   Benchmark Configuration"
echo "=============================="
echo "Arch      : $arch"
echo "Benchmark : $benchmark"
echo "Workload  : $workload"
echo "Size      : $size"
echo "Scale     : $scale"
echo "=============================="

# ========== Run Benchmark ==========

case "$benchmark" in
    spec)
        runfile="/home/gipsim/spec/${arch}/runscripts/${size}/${workload}.sh"
        echo "[INFO] Using SPEC script: $runfile"
        if [ ! -f "$runfile" ]; then
            echo "[ERROR] Script not found: $runfile"
            exit 1
        fi
        bash "$runfile" "$scale"
        ;;

    parsec)
        echo "[INFO] Preparing PARSEC run directory: ${base_dir}/run"
        mkdir -p "$base_dir/run"

        cd "$base_dir/inputs"
        tar -xvf "input_$size.tar" -C "$base_dir/run"

        m5 workbegin
        bash "/home/gipsim/parsec/$arch/runscripts/$size/$workload.sh" "$scale"
        m5 workend
        ;;

    npb)
        export OMP_NUM_THREADS="$scale"
        echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"
        m5 workbegin
        /home/gipsim/npb/NPB3.3.1/NPB3.3-OMP/bin/"$workload"."$size".x
        m5 workend
        ;;
esac

shutdown -h now
