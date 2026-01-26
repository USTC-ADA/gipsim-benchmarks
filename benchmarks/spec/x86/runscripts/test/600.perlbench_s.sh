#!/bin/bash
echo "This is a script for 600.perlbench_s.test with $1 threads"

export OMP_NUM_THREADS="$1"
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/600.perlbench_s/run

m5 --inst workbegin

cd $BASE_DIR/run_base_test_mytest-m64.0000
./perlbench_s_base.mytest-m64 -I. -I./lib makerand.pl
./perlbench_s_base.mytest-m64 -I. -I./lib test.pl

m5 --inst workend
