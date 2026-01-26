#!/bin/bash
echo "This is a script for 654.roms_s.ref with $1 threads"

export OMP_NUM_THREADS="$1"
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/654.roms_s/run

m5 --inst workbegin

cd $BASE_DIR/run_base_refspeed_mytest-64.0000
./sroms_base.mytest-64 < ocean_benchmark3.in

m5 --inst workend
