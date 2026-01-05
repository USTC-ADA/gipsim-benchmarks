#!/bin/bash
echo "This is a script for 603.bwaves_s.ref with $1 threads"

export OMP_NUM_THREADS="$1"
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/603.bwaves_s/run

m5 workbegin

cd $BASE_DIR/run_base_refspeed_mytest.0000
./speed_bwaves_base.mytest bwaves_1 < bwaves_1.in
./speed_bwaves_base.mytest bwaves_2 < bwaves_2.in

m5 workend
