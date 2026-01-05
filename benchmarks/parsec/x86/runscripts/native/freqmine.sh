cd /home/gipsim/parsec/parsec-benchmark/pkgs/apps/freqmine/run

export OMP_NUM_THREADS=$1

../inst/amd64-linux.gcc/bin/freqmine webdocs_250k.dat 11000