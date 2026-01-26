#!/bin/bash
echo "This is a script for 625.x264_s.test with $1 threads"

export OMP_NUM_THREADS="$1"
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/625.x264_s/run

m5 --inst workbegin

cd $BASE_DIR/run_base_test_mytest.0000
./x264_s_base.mytest --dumpyuv 50 --frames 156 -o BuckBunny_New.264 BuckBunny.yuv 1280x720

m5 --inst workend
