#!/bin/bash
echo "This is a script for 648.exchange2_s.ref with $1 threads"

export OMP_NUM_THREADS="$1"
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/648.exchange2_s/run

m5 --inst workbegin

cd $BASE_DIR/run_base_refspeed_mytest.0000
./exchange2_s_base.mytest 6

m5 --inst workend
