#!/bin/bash

FILE=$1
ITERATIONS=$2

total_time=0
total_task=0
total_taskCpu=0
total_cycle=0
total_inst=0
total_ref=0
total_miss=0

for ((i = 1; i <= ITERATIONS; i++)); do
  OUTPUT=$(perf stat -e task-clock,cycles,instructions,cache-references,cache-misses miniText "$FILE" 2>&1 | tee /dev/tty 2>&1 )

    TASK_CLOCK=$(echo "$OUTPUT" | grep 'task-clock' | awk '{print $1}')
    TASK_CPUS=$(echo "$OUTPUT" | grep 'task-clock' | awk '{print $5}')
    CYCLES=$(echo "$OUTPUT" | grep 'cycles' | awk '{print $1}')
    INSTRUCTIONS=$(echo "$OUTPUT" | grep 'instructions' | awk '{print $1}')
    CACHE_REFERENCES=$(echo "$OUTPUT" | grep 'cache-references' | awk '{print $1}')
    CACHE_MISSES=$(echo "$OUTPUT" | grep 'cache-misses' | awk '{print $1}')

    total_time=$((total_time + END - START))
    total_task=$(echo "$total_task + $TASK_CLOCK" | bc )
    total_taskCpu=$(echo "$total_taskCpu + $TASK_CPUS" | bc )
    total_cycle=$((total_cycle + CYCLES))
    total_inst=$((total_inst + INSTRUCTIONS))
    total_ref=$((total_ref + CACHE_REFERENCES))
    total_miss=$((total_miss + CACHE_MISSES))
done


avg_taskClock=$(echo "scale=2; $total_task / $ITERATIONS" | bc )
avg_taskCpu=$(echo "scale=2; $total_taskCpu / $ITERATIONS" | bc )
avg_timev2=$(echo "scale=2; $avg_taskClock / $avg_taskCpu" | bc )
avg_cycles=$((total_cycle / ITERATIONS))
avg_inst=$((total_inst / ITERATIONS))
avg_cacheRef=$((total_ref / ITERATIONS))
avg_cacheMiss=$((total_miss / ITERATIONS))

echo -e "\nBenchmark results for file: $FILE"
echo "Iterations: $ITERATIONS"
echo -e "---------------------------------------"

echo "Stats for miniText:"
echo "miniText average time:             ${avg_timev2} ms"
echo "miniText average task clock:       ${avg_taskClock} msec accross ${avg_taskCpu} CPUs"
# echo "miniText average cycles:           ${avg_cycles}"
echo "miniText average instructions:     ${avg_inst}"
echo "miniText average cache references: ${avg_cacheRef}"
# echo "miniText average cache misses: ${avg_cacheMiss}"
echo -e "---------------------------------------\n"

# Calculate and return the average time in milliseconds

