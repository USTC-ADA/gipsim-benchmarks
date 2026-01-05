m5 readfile > workloadfile
echo "Done reading workloads"

read -r workload size num_threads < workloadfile
echo "Workload: $workload, Size: $size, Num threads: $num_threads"

echo "Setting up Run Directory"

benchmarks=(blackscholes bodytrack facesim ferret fluidanimate freqmine raytrace swaptions vips x264)
kernel_benchmarks=(canneal dedup streamcluster)

if [[ " ${benchmarks[*]} " == *" $workload "* ]]; then
    base_dir="/home/gem5/parsec-benchmark/pkgs/apps/$workload"
elif [[ " ${kernel_benchmarks[*]} " == *" $workload "* ]]; then
    base_dir="/home/gem5/parsec-benchmark/pkgs/kernels/$workload"
else
    echo "Error: Unknown workload '$workload'"
    exit 1
fi

mkdir -p $base_dir/run
cd $base_dir/inputs

tar -xvf input_$size.tar -C $base_dir/run

m5 workbegin

/home/gem5/runscripts/$size/$workload.sh $num_threads

m5 workend