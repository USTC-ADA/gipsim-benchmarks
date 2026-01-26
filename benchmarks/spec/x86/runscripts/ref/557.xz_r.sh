#!/bin/bash
echo "This is a script for 557.xz_r.ref with $1 copies (parallel execution)"

export OMP_NUM_THREADS=1
echo "[INFO] Set OMP_NUM_THREADS = $OMP_NUM_THREADS"

BASE_DIR=/home/gipsim/spec/CPU-2017/benchspec/CPU/557.xz_r/run

for ((i = 1; i < $1; i++)); do
    extend_i=$(printf "%04d" $i)
    cp -r $BASE_DIR/run_base_refrate_mytest-m64.0000 \
          $BASE_DIR/run_base_refrate_mytest-m64.$extend_i
done

m5 --inst workbegin

for ((i = 0; i < $1; i++)); do
    extend_i=$(printf "%04d" $i)

    if [ $i -eq 0 ]; then
        (
            cd $BASE_DIR/run_base_refrate_mytest-m64.$extend_i
            ./xz_r_base.mytest-m64 cld.tar.xz 160 19cf30ae51eddcbefda78dd06014b4b96281456e078ca7c13e1c0c9e6aaea8dff3efb4ad6b0456697718cede6bd5454852652806a657bb56e07d61128434b474 59796407 61004416 6
            ./xz_r_base.mytest-m64 cpu2006docs.tar.xz 250 055ce243071129412e9dd0b3b69a21654033a9b723d874b2015c774fac1553d9713be561ca86f74e4f16f22e664fc17a79f30caa5ad2c04fbc447549c2810fae 23047774 23513385 6e
            ./xz_r_base.mytest-m64 input.combined.xz 250 a841f68f38572a49d86226b7ff5baeb31bd19dc637a922a972b2e6d1257a890f6a544ecab967c313e370478c74f760eb229d4eef8a8d2836d233d3e9dd1430bf 40401484 41217675 7
        ) &
    else
        (
            cd $BASE_DIR/run_base_refrate_mytest-m64.$extend_i
            ./xz_r_base.mytest-m64 cld.tar.xz 160 19cf30ae51eddcbefda78dd06014b4b96281456e078ca7c13e1c0c9e6aaea8dff3efb4ad6b0456697718cede6bd5454852652806a657bb56e07d61128434b474 59796407 61004416 6 > /dev/null 2>&1
            ./xz_r_base.mytest-m64 cpu2006docs.tar.xz 250 055ce243071129412e9dd0b3b69a21654033a9b723d874b2015c774fac1553d9713be561ca86f74e4f16f22e664fc17a79f30caa5ad2c04fbc447549c2810fae 23047774 23513385 6e > /dev/null 2>&1
            ./xz_r_base.mytest-m64 input.combined.xz 250 a841f68f38572a49d86226b7ff5baeb31bd19dc637a922a972b2e6d1257a890f6a544ecab967c313e370478c74f760eb229d4eef8a8d2836d233d3e9dd1430bf 40401484 41217675 7 > /dev/null 2>&1
        ) &
    fi
done

wait

m5 --inst workend
