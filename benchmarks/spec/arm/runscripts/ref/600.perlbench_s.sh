#!/bin/bash
echo "This is a script for 600.perlbench_s.ref with $1 threads"

export OMP_NUM_THREADS="$1"
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/600.perlbench_s/run

m5 workbegin

cd $BASE_DIR/run_base_refspeed_mytest-64.0000
./perlbench_s_base.mytest-64 -I./lib checkspam.pl 2500 5 25 11 150 1 1 1 1
./perlbench_s_base.mytest-64 -I./lib diffmail.pl 4 800 10 17 19 300
./perlbench_s_base.mytest-64 -I./lib splitmail.pl 6400 12 26 16 100 0

m5 workend
