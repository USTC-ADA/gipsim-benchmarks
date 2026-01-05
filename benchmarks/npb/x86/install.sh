echo "Installing NPB benchmark for x86."

echo "12345" | sudo apt-get install build-essential gfortran

cp /home/gipsim/npb/configs/suite.def /home/gipsim/npb/NPB3.3.1/NPB3.3-OMP/config/
cp /home/gipsim/npb/configs/make_x86.def /home/gipsim/npb/NPB3.3.1/NPB3.3-OMP/config/make.def

cd /home/gipsim/npb/NPB3.3.1/NPB3.3-OMP/

mkdir -p bin
make suite