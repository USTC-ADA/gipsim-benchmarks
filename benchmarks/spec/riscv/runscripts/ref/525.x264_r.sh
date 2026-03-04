#!/bin/bash
echo "This is a script for 525.x264_r.ref with $1 copies (parallel execution)"

export OMP_NUM_THREADS=1
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

export OMP_THREAD_LIMIT=1
echo "[INFO] Set OMP_THREAD_LIMIT = $OMP_THREAD_LIMIT"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/525.x264_r/run

for ((i = 1; i < $1; i++)); do
    extend_i=$(printf "%04d" $i)
    cp -r $BASE_DIR/run_base_refrate_mytest.0000 \
          $BASE_DIR/run_base_refrate_mytest.$extend_i
done

m5 --inst workbegin

for ((i = 0; i < $1; i++)); do
    extend_i=$(printf "%04d" $i)

    if [ $i -eq 0 ]; then
        (
            cd $BASE_DIR/run_base_refrate_mytest.$extend_i
            ./x264_r_base.mytest --pass 1 --stats x264_stats.log --bitrate 1000 --frames 1000 -o BuckBunny_New.264 BuckBunny.yuv 1280x720
            ./x264_r_base.mytest --pass 2 --stats x264_stats.log --bitrate 1000 --dumpyuv 200 --frames 1000 -o BuckBunny_New.264 BuckBunny.yuv 1280x720
            ./x264_r_base.mytest --seek 500 --dumpyuv 200 --frames 1250 -o BuckBunny_New.264 BuckBunny.yuv 1280x720
        ) &
    else
        (
            cd $BASE_DIR/run_base_refrate_mytest.$extend_i
            ./x264_r_base.mytest --pass 1 --stats x264_stats.log --bitrate 1000 --frames 1000 -o BuckBunny_New.264 BuckBunny.yuv 1280x720 > /dev/null 2>&1
            ./x264_r_base.mytest --pass 2 --stats x264_stats.log --bitrate 1000 --dumpyuv 200 --frames 1000 -o BuckBunny_New.264 BuckBunny.yuv 1280x720 > /dev/null 2>&1
            ./x264_r_base.mytest --seek 500 --dumpyuv 200 --frames 1250 -o BuckBunny_New.264 BuckBunny.yuv 1280x720 > /dev/null 2>&1
        ) &
    fi
done

wait

m5 --inst workend
