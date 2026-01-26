#!/bin/bash
echo "This is a script for 602.gcc_s.ref with $1 threads"

export OMP_NUM_THREADS="$1"
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/602.gcc_s/run

m5 --inst workbegin

cd $BASE_DIR/run_base_refspeed_mytest-64.0000
./sgcc_base.mytest-64 gcc-pp.c -O5 -fipa-pta -o gcc-pp.opts-O5_-fipa-pta.s
./sgcc_base.mytest-64 gcc-pp.c -O5 -finline-limit=1000 -fselective-scheduling -fselective-scheduling2 -o gcc-pp.opts-O5_-finline-limit_1000_-fselective-scheduling_-fselective-scheduling2.s
./sgcc_base.mytest-64 gcc-pp.c -O5 -finline-limit=24000 -fgcse -fgcse-las -fgcse-lm -fgcse-sm -o gcc-pp.opts-O5_-finline-limit_24000_-fgcse_-fgcse-las_-fgcse-lm_-fgcse-sm.s

m5 --inst workend
