#!/bin/bash
echo "This is a script for 998.specrand_is.test with $1 threads"

export OMP_NUM_THREADS="$1"
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/998.specrand_is/run

m5 workbegin

cd $BASE_DIR/run_base_test_mytest-m64.0000
./specrand_is_base.mytest-m64 324342 24239

m5 workend
