#!/bin/bash

# Benchmark parameters
TASK_SIZE=${1:-20000000}
NUM_TASKS=${2:-14}

run_benchmark() {
    local cmd="$1"
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
with open('/tmp/c_single_time', 'w') as f:
    f.write(str(avg))
" > /tmp/c_single_stats

    python3 -c "
import math
times_str = '${times[*]}'
times = [float(t) / 1e9 for t in times_str.split()]
avg = sum(times)/len(times)
std = math.sqrt(sum((x - avg)**2 for x in times) / len(times))
print(f'| avg: {avg:.3f}±{std:.3f}s, min: {min(times):.3f}s, max: {max(times):.3f}s')
with open('/tmp/c_multi_time', 'w') as f:
    f.write(str(avg))
" > /tmp/c_multi_stats
}

echo "Task Size: $TASK_SIZE, Num Tasks: $NUM_TASKS"

# Compile C programs
gcc -o c_single c_single.c -lm
gcc -o c_multi c_multi.c -lm -lpthread

echo -n "C Single Thread:      "
run_benchmark "./c_single $TASK_SIZE $NUM_TASKS"
c_single=$(cat /tmp/c_single_time)
cat /tmp/c_single_stats

echo -n "C Multi Thread:       "
run_benchmark "./c_multi $TASK_SIZE $NUM_TASKS"
c_multi=$(cat /tmp/c_multi_time)
cat /tmp/c_multi_stats

echo "C Thread vs Single: $(python3 -c "print(f'{$c_single/$c_multi:.2f}x')")"