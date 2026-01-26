echo "Installing PARSEC benchmark for x86."

cd /home/gipsim/parsec
tar -xzf parsec-3.0-core.tar.gz -C ./parsec-benchmark --strip-components=1 --skip-old-files
tar -xzf parsec-3.0-input-sim.tar.gz -C ./parsec-benchmark --strip-components=1 --skip-old-files
tar -xzf parsec-3.0-input-native.tar.gz -C ./parsec-benchmark --strip-components=1 --skip-old-files

rm parsec-3.0-core.tar.gz parsec-3.0-input-sim.tar.gz parsec-3.0-input-native.tar.gz

echo "* libraries/restart-without-asking boolean true" | sudo debconf-set-selections

echo "12345" | sudo -S apt update
echo "12345" | sudo -S apt install -y   debconf-utils \
                                        autotools-dev \
                                        automake \
                                        m4 \
                                        git \
                                        python \
                                        python-dev \
                                        gettext \
                                        libx11-dev \
                                        libxext-dev \
                                        xorg-dev \
                                        unzip \
                                        texinfo \
                                        freeglut3-dev \
                                        cmake

echo "12345" | sudo -S chown gipsim -R parsec-benchmark/
echo "12345" | sudo -S chgrp gipsim -R parsec-benchmark/

cd parsec-benchmark

source env.sh

parsecmgmt -a build -p libtool
parsecmgmt -a build -p hooks

parsecmgmt -a build -p blackscholes -c gcc
parsecmgmt -a build -p bodytrack -c gcc
parsecmgmt -a build -p canneal -c gcc
parsecmgmt -a build -p dedup -c gcc
parsecmgmt -a build -p facesim -c gcc
parsecmgmt -a build -p ferret -c gcc
parsecmgmt -a build -p fluidanimate -c gcc
parsecmgmt -a build -p freqmine -c gcc
parsecmgmt -a build -p streamcluster -c gcc
parsecmgmt -a build -p swaptions -c gcc
parsecmgmt -a build -p vips -c gcc
parsecmgmt -a build -p x264 -c gcc

echo "12345" | sudo -S chown gipsim -R /usr/local/
echo "12345" | sudo -S chgrp gipsim -R /usr/local/

parsecmgmt -a build -p raytrace -c gcc

cp -r /usr/local/bin/ /home/gipsim/parsec/parsec-benchmark/pkgs/tools/cmake/inst/amd64-linux.gcc/

parsecmgmt -a build -p raytrace -c gcc

cp -r /usr/local/bin/ /home/gipsim/parsec/parsec-benchmark/pkgs/apps/raytrace/inst/amd64-linux.gcc/

echo "12345" | sudo -S chown root -R /usr/local/
echo "12345" | sudo -S chgrp root -R /usr/local/

cd ..
echo "12345" | sudo -S chown gipsim:gipsim -R parsec-benchmark/