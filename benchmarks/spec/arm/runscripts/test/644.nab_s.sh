#!/bin/bash
echo "This is a script for 644.nab_s.test with $1 threads"

export OMP_NUM_THREADS="$1"
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/644.nab_s/run

m5 workbegin

cd $BASE_DIR/run_base_test_mytest-64.0000
./nab_s_base.mytest-64 hkrdenq 1930344093 1000

m5 workend
