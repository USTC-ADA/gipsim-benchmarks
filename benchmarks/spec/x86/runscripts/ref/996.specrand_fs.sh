#!/bin/bash
echo "This is a script for 996.specrand_fs.ref with $1 threads"

export OMP_NUM_THREADS="$1"
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/996.specrand_fs/run


m5 --inst workbegin

cd $BASE_DIR/run_base_refspeed_mytest-m64.0000
./specrand_fs_base.mytest-m64 1255432124 234923

m5 --inst workend
