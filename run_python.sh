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
with open('/tmp/py_${label}_time', 'w') as f:
    f.write(str(avg))
"
}

echo "Task Size: $TASK_SIZE, Num Tasks: $NUM_TASKS"

echo -n "Python Single Thread: "
run_benchmark "python3 single_thread.py $TASK_SIZE $NUM_TASKS" "single"
py_single=$(cat /tmp/py_single_time)

echo -n "Python Multi Thread:  "
run_benchmark "python3 multi_thread.py $TASK_SIZE $NUM_TASKS" "multi"
py_multi=$(cat /tmp/py_multi_time)

echo -n "Python Multi Process: "
run_benchmark "python3 multi_process.py $TASK_SIZE $NUM_TASKS" "process"
py_process=$(cat /tmp/py_process_time)

python3 -c "
py_single = $py_single
py_multi = $py_multi
py_process = $py_process

print(f'Python Thread vs Single:    {py_single/py_multi:.2f}x')
print(f'Python Process vs Single:  {py_single/py_process:.2f}x')
"