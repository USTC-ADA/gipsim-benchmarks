#!/bin/bash
echo "This is a script for 638.imagick_s.test with $1 threads"

export OMP_NUM_THREADS="$1"
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/638.imagick_s/run

m5 workbegin

cd $BASE_DIR/run_base_test_mytest.0000
./imagick_s_base.mytest -limit disk 0 test_input.tga -shear 25 -resize 640x480 -negate -alpha Off test_output.tga

m5 workend
