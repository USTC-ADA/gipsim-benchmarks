#!/bin/bash
echo "This is a script for 526.blender_r.test with $1 copies (parallel execution)"

export OMP_NUM_THREADS=1
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/526.blender_r/run

for ((i = 1; i < $1; i++)); do
    extend_i=$(printf "%04d" $i)
    cp -r $BASE_DIR/run_base_test_mytest-64.0000 \
          $BASE_DIR/run_base_test_mytest-64.$extend_i
done

m5 --inst workbegin

for ((i = 0; i < $1; i++)); do
    extend_i=$(printf "%04d" $i)

    if [ $i -eq 0 ]; then
        (
            cd $BASE_DIR/run_base_test_mytest-64.$extend_i
            ./blender_r_base.mytest-64 cube.blend --render-output cube_ --threads 1 -b -F RAWTGA -s 1 -e 1 -a
        ) &
    else
        (
            cd $BASE_DIR/run_base_test_mytest-64.$extend_i
            ./blender_r_base.mytest-64 cube.blend --render-output cube_ --threads 1 -b -F RAWTGA -s 1 -e 1 -a > /dev/null 2>&1
        ) &
    fi
done

wait

m5 --inst workend
