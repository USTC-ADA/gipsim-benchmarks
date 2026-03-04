#!/bin/bash
echo "This is a script for 502.gcc_r.ref with $1 copies (parallel execution)"

export OMP_NUM_THREADS=1
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

export OMP_THREAD_LIMIT=1
echo "[INFO] Set OMP_THREAD_LIMIT = $OMP_THREAD_LIMIT"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/502.gcc_r/run

for ((i = 1; i < $1; i++)); do
    extend_i=$(printf "%04d" $i)
    cp -r $BASE_DIR/run_base_refrate_mytest-64.0000 \
          $BASE_DIR/run_base_refrate_mytest-64.$extend_i
done

m5 --inst workbegin

for ((i = 0; i < $1; i++)); do
    extend_i=$(printf "%04d" $i)

    if [ $i -eq 0 ]; then
        (
            cd $BASE_DIR/run_base_refrate_mytest-64.$extend_i
            ./cpugcc_r_base.mytest-64 gcc-pp.c -O3 -finline-limit=0 -fif-conversion -fif-conversion2 -o gcc-pp.opts-O3_-finline-limit_0_-fif-conversion_-fif-conversion2.s
            ./cpugcc_r_base.mytest-64 gcc-pp.c -O2 -finline-limit=36000 -fpic -o gcc-pp.opts-O2_-finline-limit_36000_-fpic.s
            ./cpugcc_r_base.mytest-64 gcc-smaller.c -O3 -fipa-pta -o gcc-smaller.opts-O3_-fipa-pta.s
            ./cpugcc_r_base.mytest-64 ref32.c -O5 -o ref32.opts-O5.s
            ./cpugcc_r_base.mytest-64 ref32.c -O3 -fselective-scheduling -fselective-scheduling2 -o ref32.opts-O3_-fselective-scheduling_-fselective-scheduling2.s
        ) &
    else
        (
            cd $BASE_DIR/run_base_refrate_mytest-64.$extend_i
            ./cpugcc_r_base.mytest-64 gcc-pp.c -O3 -finline-limit=0 -fif-conversion -fif-conversion2 -o gcc-pp.opts-O3_-finline-limit_0_-fif-conversion_-fif-conversion2.s > /dev/null 2>&1
            ./cpugcc_r_base.mytest-64 gcc-pp.c -O2 -finline-limit=36000 -fpic -o gcc-pp.opts-O2_-finline-limit_36000_-fpic.s > /dev/null 2>&1
            ./cpugcc_r_base.mytest-64 gcc-smaller.c -O3 -fipa-pta -o gcc-smaller.opts-O3_-fipa-pta.s > /dev/null 2>&1
            ./cpugcc_r_base.mytest-64 ref32.c -O5 -o ref32.opts-O5.s > /dev/null 2>&1
            ./cpugcc_r_base.mytest-64 ref32.c -O3 -fselective-scheduling -fselective-scheduling2 -o ref32.opts-O3_-fselective-scheduling_-fselective-scheduling2.s > /dev/null 2>&1
        ) &
    fi
done

wait

m5 --inst workend
