#!/bin/bash
echo "This is a script for 621.wrf_s.test with $1 threads"

export OMP_NUM_THREADS="$1"
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/621.wrf_s/run

m5 --inst workbegin

cd $BASE_DIR/run_base_test_mytest.0000
./wrf_s_base.mytest

m5 --inst workend
