#!/usr/bin/env python3
import math
import sys
import time

def cpu_bound_task(n):
    total = 0.0
    for i in range(n):
        fi = float(i)
        total += fi * fi
        total += math.sqrt(fi)
        total += fi * 3.14159
        total += abs(fi - 1000)
        total += float(int(fi / 2))
        total += math.sin(fi)
        total += math.cos(fi)
    return total

def main():
    task_size = int(sys.argv[1])
    num_tasks = int(sys.argv[2])
    
    start = time.time_ns()
    results = [cpu_bound_task(task_size) for _ in range(num_tasks)]
    end = time.time_ns()
    
    print(end - start)

if __name__ == "__main__":
    main()