#!/bin/bash
echo "This is a script for 502.gcc_r.test with $1 copies (parallel execution)"

export OMP_NUM_THREADS=1
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/502.gcc_r/run

for ((i = 1; i < $1; i++)); do
    extend_i=$(printf "%04d" $i)
    cp -r $BASE_DIR/run_base_test_mytest-64.0000 \
          $BASE_DIR/run_base_test_mytest-64.$extend_i
done

m5 workbegin

for ((i = 0; i < $1; i++)); do
    extend_i=$(printf "%04d" $i)

    if [ $i -eq 0 ]; then
        (
            cd $BASE_DIR/run_base_test_mytest-64.$extend_i
            ./cpugcc_r_base.mytest-64 t1.c -O3 -finline-limit=50000 -o t1.opts-O3_-finline-limit_50000.s
        ) &
    else
        (
            cd $BASE_DIR/run_base_test_mytest-64.$extend_i
            ./cpugcc_r_base.mytest-64 t1.c -O3 -finline-limit=50000 -o t1.opts-O3_-finline-limit_50000.s > /dev/null 2>&1
        ) &
    fi
done

wait

m5 workend
