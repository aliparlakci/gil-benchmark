#!/bin/bash

# Benchmark parameters
TASK_SIZE=${1:-20000000}
NUM_TASKS=${2:-14}

run_benchmark() {
    local cmd="$1"
    local label="$2"
    local times=()
    
    for i in {1..5}; do
        time_output=$($cmd)
        times+=("$time_output")
        echo -n "$(printf "%.3f" $(echo "$time_output / 1000000000" | bc -l))s "
    done
    
    # Calculate stats (convert nanoseconds to seconds)
    python3 -c "
import math
times_str = '${times[*]}'
times = [float(t) / 1e9 for t in times_str.split()]
avg = sum(times)/len(times)
std = math.sqrt(sum((x - avg)**2 for x in times) / len(times))
print(f'| avg: {avg:.3f}±{std:.3f}s, min: {min(times):.3f}s, max: {max(times):.3f}s')
with open('/tmp/go_${label}_time', 'w') as f:
    f.write(str(avg))
"
}

echo "Task Size: $TASK_SIZE, Num Tasks: $NUM_TASKS"

# Compile Go programs
go build -o go_single go_single.go
go build -o go_multi go_multi.go

echo -n "Go Single Thread:     "
run_benchmark "./go_single $TASK_SIZE $NUM_TASKS" "single"
go_single=$(cat /tmp/go_single_time)

echo -n "Go Multi Thread:      "
run_benchmark "./go_multi $TASK_SIZE $NUM_TASKS" "multi"
go_multi=$(cat /tmp/go_multi_time)

echo "Go Goroutine vs Single: $(python3 -c "print(f'{$go_single/$go_multi:.2f}x')")"