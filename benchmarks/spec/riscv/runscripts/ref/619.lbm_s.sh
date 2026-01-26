#!/bin/bash
echo "This is a script for 619.lbm_s.ref with $1 threads"

export OMP_NUM_THREADS="$1"
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/619.lbm_s/run

m5 --inst workbegin

cd $BASE_DIR/run_base_refspeed_mytest.0000
./lbm_s_base.mytest 2000 reference.dat 0 0 200_200_260_ldc.of

m5 --inst workend
