#!/bin/bash
echo "This is a script for 602.gcc_s.test with $1 threads"

export OMP_NUM_THREADS="$1"
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/602.gcc_s/run

m5 workbegin

cd $BASE_DIR/run_base_test_mytest.0000
./sgcc_base.mytest t1.c -O3 -finline-limit=50000 -o t1.opts-O3_-finline-limit_50000.s

m5 workend
