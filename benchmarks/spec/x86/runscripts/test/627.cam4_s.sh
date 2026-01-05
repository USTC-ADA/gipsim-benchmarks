#!/bin/bash
echo "This is a script for 627.cam4_s.test with $1 threads"

export OMP_NUM_THREADS="$1"
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/627.cam4_s/run

m5 workbegin

cd $BASE_DIR/run_base_test_mytest-m64.0000
./cam4_s_base.mytest-m64

m5 workend
