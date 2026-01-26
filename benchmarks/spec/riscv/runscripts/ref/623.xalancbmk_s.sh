#!/bin/bash
echo "This is a script for 623.xalancbmk_s.ref with $1 threads"

export OMP_NUM_THREADS="$1"
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/623.xalancbmk_s/run

m5 --inst workbegin

cd $BASE_DIR/run_base_refspeed_mytest.0000
./xalancbmk_s_base.mytest -v t5.xml xalanc.xsl

m5 --inst workend
