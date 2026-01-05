cd /home/gipsim/parsec/parsec-benchmark/pkgs/apps/vips/run

export IM_CONCURRENCY=$1

../inst/amd64-linux.gcc/bin/vips im_benchmark vulture_2336x2336.v output.v
