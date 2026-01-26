#!/bin/bash
echo "This is a script for 631.deepsjeng_s.test with $1 threads"

export OMP_NUM_THREADS="$1"
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/631.deepsjeng_s/run

m5 --inst workbegin

cd $BASE_DIR/run_base_test_mytest-m64.0000
./deepsjeng_s_base.mytest-m64 test.txt

m5 --inst workend
