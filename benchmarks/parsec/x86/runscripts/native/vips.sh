cd /home/gipsim/parsec/parsec-benchmark/pkgs/apps/vips/run

export IM_CONCURRENCY=$1

../inst/amd64-linux.gcc/bin/vips im_benchmark orion_18000x18000.v output.v
