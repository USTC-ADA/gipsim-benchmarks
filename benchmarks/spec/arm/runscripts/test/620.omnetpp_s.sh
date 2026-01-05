#!/bin/bash
echo "This is a script for 620.omnetpp_s.test with $1 threads"

export OMP_NUM_THREADS="$1"
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/620.omnetpp_s/run

m5 workbegin

cd $BASE_DIR/run_base_test_mytest-64.0000
./omnetpp_s_base.mytest-64 -c General -r 0

m5 workend
