#!/bin/bash
echo "This is a script for 628.pop2_s.ref with $1 threads"

export OMP_NUM_THREADS="$1"
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/628.pop2_s/run

m5 workbegin

cd $BASE_DIR/run_base_refspeed_mytest-m64.0000
./speed_pop2_base.mytest-m64

m5 workend
