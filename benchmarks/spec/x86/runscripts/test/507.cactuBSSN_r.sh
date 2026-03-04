#!/bin/bash
echo "This is a script for 507.cactuBSSN_r.test with $1 copies (parallel execution)"

export OMP_NUM_THREADS=1
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

export OMP_THREAD_LIMIT=1
echo "[INFO] Set OMP_THREAD_LIMIT = $OMP_THREAD_LIMIT"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/507.cactuBSSN_r/run

for ((i = 1; i < $1; i++)); do
    extend_i=$(printf "%04d" $i)
    cp -r $BASE_DIR/run_base_test_mytest-m64.0000 \
          $BASE_DIR/run_base_test_mytest-m64.$extend_i
done

m5 --inst workbegin

for ((i = 0; i < $1; i++)); do
    extend_i=$(printf "%04d" $i)

    if [ $i -eq 0 ]; then
        (
            cd $BASE_DIR/run_base_test_mytest-m64.$extend_i
            ./cactusBSSN_r_base.mytest-m64 spec_test.par
        ) &
    else
        (
            cd $BASE_DIR/run_base_test_mytest-m64.$extend_i
            ./cactusBSSN_r_base.mytest-m64 spec_test.par > /dev/null 2>&1
        ) &
    fi
done

wait

m5 --inst workend
