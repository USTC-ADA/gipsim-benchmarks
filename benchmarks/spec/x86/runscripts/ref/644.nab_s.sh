#!/bin/bash
echo "This is a script for 644.nab_s.ref with $1 threads"

export OMP_NUM_THREADS="$1"
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/644.nab_s/run

m5 workbegin

cd $BASE_DIR/run_base_refspeed_mytest-m64.0000
./nab_s_base.mytest-m64 3j1n 20140317 220

m5 workend
