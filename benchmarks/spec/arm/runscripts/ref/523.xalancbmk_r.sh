#!/bin/bash
echo "This is a script for 523.xalancbmk_r.ref with $1 copies (parallel execution)"

export OMP_NUM_THREADS=1
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/523.xalancbmk_r/run

for ((i = 1; i < $1; i++)); do
    extend_i=$(printf "%04d" $i)
    cp -r $BASE_DIR/run_base_refrate_mytest-64.0000 \
          $BASE_DIR/run_base_refrate_mytest-64.$extend_i
done

m5 workbegin

for ((i = 0; i < $1; i++)); do
    extend_i=$(printf "%04d" $i)

    if [ $i -eq 0 ]; then
        (
            cd $BASE_DIR/run_base_refrate_mytest-64.$extend_i
            ./cpuxalan_r_base.mytest-64 -v t5.xml xalanc.xsl
        ) &
    else
        (
            cd $BASE_DIR/run_base_refrate_mytest-64.$extend_i
            ./cpuxalan_r_base.mytest-64 -v t5.xml xalanc.xsl > /dev/null 2>&1
        ) &
    fi
done

wait

m5 workend
