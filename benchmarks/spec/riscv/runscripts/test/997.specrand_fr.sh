#!/bin/bash
echo "This is a script for 997.specrand_fr.test with $1 copies (parallel execution)"

export OMP_NUM_THREADS=1
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

export OMP_THREAD_LIMIT=1
echo "[INFO] Set OMP_THREAD_LIMIT = $OMP_THREAD_LIMIT"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/997.specrand_fr/run

for ((i = 1; i < $1; i++)); do
    extend_i=$(printf "%04d" $i)
    cp -r $BASE_DIR/run_base_test_mytest.0000 \
          $BASE_DIR/run_base_test_mytest.$extend_i
done

m5 --inst workbegin

for ((i = 0; i < $1; i++)); do
    extend_i=$(printf "%04d" $i)

    if [ $i -eq 0 ]; then
        (
            cd $BASE_DIR/run_base_test_mytest.$extend_i
            ./specrand_fr_base.mytest 324342 24239
        ) &
    else
        (
            cd $BASE_DIR/run_base_test_mytest.$extend_i
            ./specrand_fr_base.mytest 324342 24239 > /dev/null 2>&1
        ) &
    fi
done

wait

m5 --inst workend
