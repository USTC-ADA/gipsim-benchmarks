#!/bin/bash
echo "This is a script for 503.bwaves_r.ref with $1 copies (parallel execution)"

export OMP_NUM_THREADS=1
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/503.bwaves_r/run

for ((i = 1; i < $1; i++)); do
    extend_i=$(printf "%04d" $i)
    cp -r $BASE_DIR/run_base_refrate_mytest-m64.0000 \
          $BASE_DIR/run_base_refrate_mytest-m64.$extend_i
done

m5 --inst workbegin

for ((i = 0; i < $1; i++)); do
    extend_i=$(printf "%04d" $i)

    if [ $i -eq 0 ]; then
        (
            cd $BASE_DIR/run_base_refrate_mytest-m64.$extend_i
            ./bwaves_r_base.mytest-m64 bwaves_1 < bwaves_1.in
            ./bwaves_r_base.mytest-m64 bwaves_2 < bwaves_2.in
            ./bwaves_r_base.mytest-m64 bwaves_3 < bwaves_3.in
            ./bwaves_r_base.mytest-m64 bwaves_4 < bwaves_4.in
        ) &
    else
        (
            cd $BASE_DIR/run_base_refrate_mytest-m64.$extend_i
            ./bwaves_r_base.mytest-m64 bwaves_1 < bwaves_1.in > /dev/null 2>&1
            ./bwaves_r_base.mytest-m64 bwaves_2 < bwaves_2.in > /dev/null 2>&1
            ./bwaves_r_base.mytest-m64 bwaves_3 < bwaves_3.in > /dev/null 2>&1
            ./bwaves_r_base.mytest-m64 bwaves_4 < bwaves_4.in > /dev/null 2>&1
        ) &
    fi
done

wait

m5 --inst workend
