#!/bin/bash
echo "This is a script for 544.nab_r.test with $1 copies (parallel execution)"

export OMP_NUM_THREADS=1
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/544.nab_r/run

for ((i = 1; i < $1; i++)); do
    extend_i=$(printf "%04d" $i)
    cp -r $BASE_DIR/run_base_test_mytest-m64.0000 \
          $BASE_DIR/run_base_test_mytest-m64.$extend_i
done

m5 workbegin

for ((i = 0; i < $1; i++)); do
    extend_i=$(printf "%04d" $i)

    if [ $i -eq 0 ]; then
        (
            cd $BASE_DIR/run_base_test_mytest-m64.$extend_i
            ./nab_r_base.mytest-m64 hkrdenq 1930344093 1000
        ) &
    else
        (
            cd $BASE_DIR/run_base_test_mytest-m64.$extend_i
            ./nab_r_base.mytest-m64 hkrdenq 1930344093 1000 > /dev/null 2>&1
        ) &
    fi
done

wait

m5 workend
