#!/bin/bash
echo "Benchmark: $1, Workload: $2, Size: $3, Scale: $4"
echo "$1 $2 $3 $4" > /workloadfile

exec /sbin/init