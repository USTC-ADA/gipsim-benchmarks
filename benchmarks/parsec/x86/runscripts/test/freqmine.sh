cd /home/gipsim/parsec/parsec-benchmark/pkgs/apps/freqmine/run

export OMP_NUM_THREADS=$1

../inst/amd64-linux.gcc/bin/freqmine T10I4D100K_3.dat 1