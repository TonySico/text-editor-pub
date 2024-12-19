#!/bin/bash

# Ensure the script is called with the correct arguments
if [[ $# -lt 3 ]]; then
    echo "Usage: $0 <file_path> <iterations> <editor_list>"
    echo "Editor list should be a comma-separated list (e.g., vim,vi,emacs,nano)"
    exit 1
fi

FILE=$1
ITERATIONS=$2
EDITORS=$(echo $3 | tr ',' ' ')

# Validate the file exists
if [[ ! -f "$FILE" ]]; then
    echo "Error: File '$FILE' does not exist."
    exit 1
fi

# Validate the number of iterations
if ! [[ "$ITERATIONS" =~ ^[0-9]+$ ]]; then
    echo "Error: Iterations must be a positive integer."
    exit 1
fi

# Function to benchmark an editor
benchmark_editor() {
    local editor=$1
    local total_time=0
    local total_task=0
    local total_taskCpu=0
    local total_cycle=0
    local total_inst=0
    local total_ref=0
    local total_miss=0

    for ((i = 1; i <= ITERATIONS; i++)); do
        case $editor in
            vim)
                OUTPUT=$(perf stat -e task-clock,cycles,instructions,cache-references,cache-misses vim -n -es "$FILE" -c ':q' 2>&1)

                TASK_CLOCK=$(echo "$OUTPUT" | grep 'task-clock' | awk '{print $1}')
                TASK_CPUS=$(echo "$OUTPUT" | grep 'task-clock' | awk '{print $5}')
                CYCLES=$(echo "$OUTPUT" | grep 'cycles' | awk '{print $1}')
                INSTRUCTIONS=$(echo "$OUTPUT" | grep 'instructions' | awk '{print $1}')
                CACHE_REFERENCES=$(echo "$OUTPUT" | grep 'cache-references' | awk '{print $1}')
                CACHE_MISSES=$(echo "$OUTPUT" | grep 'cache-misses' | awk '{print $1}')
                ;;
            vi)
                OUTPUT=$(perf stat -e task-clock,cycles,instructions,cache-references,cache-misses vi +':q' "$FILE" 2>&1)

                TASK_CLOCK=$(echo "$OUTPUT" | grep 'task-clock' | awk '{print $1}')
                TASK_CPUS=$(echo "$OUTPUT" | grep 'task-clock' | awk '{print $5}')
                CYCLES=$(echo "$OUTPUT" | grep 'cycles' | awk '{print $1}')
                INSTRUCTIONS=$(echo "$OUTPUT" | grep 'instructions' | awk '{print $1}')
                CACHE_REFERENCES=$(echo "$OUTPUT" | grep 'cache-references' | awk '{print $1}')
                CACHE_MISSES=$(echo "$OUTPUT" | grep 'cache-misses' | awk '{print $1}')
                ;;
            emacs)
                OUTPUT=$(perf stat -e task-clock,cycles,instructions,cache-references,cache-misses emacs --batch --eval '(setq large-file-warning-threshold nil)' "$FILE" --eval '(kill-emacs)' 2>&1)

                TASK_CLOCK=$(echo "$OUTPUT" | grep 'task-clock' | awk '{print $1}')
                TASK_CPUS=$(echo "$OUTPUT" | grep 'task-clock' | awk '{print $5}')
                CYCLES=$(echo "$OUTPUT" | grep 'cycles' | awk '{print $1}')
                INSTRUCTIONS=$(echo "$OUTPUT" | grep 'instructions' | awk '{print $1}')
                CACHE_REFERENCES=$(echo "$OUTPUT" | grep 'cache-references' | awk '{print $1}')
                CACHE_MISSES=$(echo "$OUTPUT" | grep 'cache-misses' | awk '{print $1}')
                ;;
            nano)
                OUTPUT=$(perf stat -e task-clock,cycles,instructions,cache-references,cache-misses script -q -c "printf '\x18' | nano $FILE" 2>&1)

                TASK_CLOCK=$(echo "$OUTPUT" | grep 'task-clock' | awk '{print $1}')
                TASK_CPUS=$(echo "$OUTPUT" | grep 'task-clock' | awk '{print $5}')
                CYCLES=$(echo "$OUTPUT" | grep 'cycles' | awk '{print $1}')
                INSTRUCTIONS=$(echo "$OUTPUT" | grep 'instructions' | awk '{print $1}')
                CACHE_REFERENCES=$(echo "$OUTPUT" | grep 'cache-references' | awk '{print $1}')
                CACHE_MISSES=$(echo "$OUTPUT" | grep 'cache-misses' | awk '{print $1}')
                ;;
            *)
                echo "Error: Unsupported editor '$editor'."
                return 1
                ;;
        esac
        total_task=$(echo "$total_task + $TASK_CLOCK" | bc )
        total_taskCpu=$(echo "$total_taskCpu + $TASK_CPUS" | bc )
        total_cycle=$((total_cycle + CYCLES))
        total_inst=$((total_inst + INSTRUCTIONS))
        total_ref=$((total_ref + CACHE_REFERENCES))
        total_miss=$((total_miss + CACHE_MISSES))
    done

    # Calculate and return the average time in milliseconds
    avg_taskClock=$(echo "scale=2; $total_task / $ITERATIONS" | bc )
    avg_taskCpu=$(echo "scale=2; $total_taskCpu / $ITERATIONS" | bc )
    avg_timev2=$(echo "scale=2; $avg_taskClock / $avg_taskCpu" | bc )
    avg_cycles=$((total_cycle / ITERATIONS))
    avg_inst=$((total_inst / ITERATIONS))
    avg_cacheRef=$((total_ref / ITERATIONS))
    avg_cacheMiss=$((total_miss / ITERATIONS))

    echo "${editor} average time:             ${avg_timev2} ms"
    echo "${editor} average task clock:       ${avg_taskClock} msec accross ${avg_taskCpu} CPUs"
    # echo "${editor} average cycles:           ${avg_cycles}"
    echo "${editor} average instructions:     ${avg_inst}"
    echo "${editor} average cache references: ${avg_cacheRef}"
    # echo "${editor} average cache misses: ${avg_cacheMiss}"
}

# Print results
for editor in $EDITORS; do
    if command -v "$editor" &> /dev/null; then
        echo "Stats for ${editor}:"
        benchmark_editor "$editor"
echo -e "---------------------------------------\n"
    else
        echo "Error: $editor not found on the system."
    fi
done

echo -e "---------------------------------------\n"

