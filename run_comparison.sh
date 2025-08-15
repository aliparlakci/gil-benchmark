#!/bin/bash

# Benchmark parameters
TASK_SIZE=20000000
NUM_TASKS=14

# Run individual language benchmarks
./run_c.sh $TASK_SIZE $NUM_TASKS
echo
./run_go.sh $TASK_SIZE $NUM_TASKS
echo
./run_python.sh $TASK_SIZE $NUM_TASKS
