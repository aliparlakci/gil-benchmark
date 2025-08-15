#!/bin/bash

# Benchmark parameters
TASK_SIZE=20000000
NUM_TASKS=14

run_benchmark() {
    local cmd="$1"
    local times=()
    
    for i in {1..5}; do
        time_output=$($cmd)
        times+=("$time_output")
    done
    
    # Calculate stats (convert nanoseconds to seconds)
    python3 -c "
import math
times_str = '${times[*]}'
times = [float(t) / 1e9 for t in times_str.split()]
avg = sum(times)/len(times)
std = math.sqrt(sum((x - avg)**2 for x in times) / len(times))
print(f'avg: {avg:.3f}±{std:.3f}s, min: {min(times):.3f}s, max: {max(times):.3f}s')
with open('/tmp/avg_time', 'w') as f:
    f.write(str(avg))
"
}

echo "Python GIL vs Go Benchmark Results (5 runs each)"
echo "Task Size: $TASK_SIZE, Num Tasks: $NUM_TASKS"
echo "================================================"
echo

# Compile Go programs first
go build -o go_single go_single.go
go build -o go_multi go_multi.go

echo -n "Go Single Thread:     "
run_benchmark "./go_single $TASK_SIZE $NUM_TASKS"
go_single=$(cat /tmp/avg_time)

echo -n "Go Multi Thread:      "
run_benchmark "./go_multi $TASK_SIZE $NUM_TASKS"
go_multi=$(cat /tmp/avg_time)

python3 -c "
go_single = $go_single
go_multi = $go_multi

print(f'Go Multi vs Single:        {go_single/go_multi:.2f}x speedup')
"

echo -n "Python Single Thread: "
run_benchmark "python3 single_thread.py $TASK_SIZE $NUM_TASKS"
py_single=$(cat /tmp/avg_time)

echo -n "Python Multi Thread:  "
run_benchmark "python3 multi_thread.py $TASK_SIZE $NUM_TASKS"
py_multi=$(cat /tmp/avg_time)

echo -n "Python Multi Process: "
run_benchmark "python3 multi_process.py $TASK_SIZE $NUM_TASKS"
py_process=$(cat /tmp/avg_time)

python3 -c "
go_single = $go_single
go_multi = $go_multi
py_single = $py_single
py_multi = $py_multi
py_process = $py_process

print(f'Go Multi vs Single:        {go_single/go_multi:.2f}x speedup')
print(f'Python Multi vs Single:    {py_single/py_multi:.2f}x (slower due to GIL)')
print(f'Python Process vs Single:  {py_single/py_process:.2f}x speedup')
"