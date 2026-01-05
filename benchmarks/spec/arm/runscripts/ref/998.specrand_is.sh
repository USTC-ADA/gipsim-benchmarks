#!/bin/bash
echo "This is a script for 998.specrand_is.ref with $1 threads"

export OMP_NUM_THREADS="$1"
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/998.specrand_is/run

m5 workbegin

cd $BASE_DIR/run_base_refspeed_mytest-64.0000
./specrand_is_base.mytest-64 1255432124 234923

m5 workend
