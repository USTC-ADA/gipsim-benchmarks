cd /home/gipsim/parsec/parsec-benchmark/pkgs/apps/vips/run

export IM_CONCURRENCY=$1

../inst/amd64-linux.gcc/bin/vips im_benchmark pomegranate_1600x1200.v output.v
