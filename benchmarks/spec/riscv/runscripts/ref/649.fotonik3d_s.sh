#!/bin/bash
echo "This is a script for 649.fotonik3d_s.ref with $1 threads"

export OMP_NUM_THREADS="$1"
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/649.fotonik3d_s/run

m5 workbegin

cd $BASE_DIR/run_base_refspeed_mytest.0000
./fotonik3d_s_base.mytest

m5 workend
