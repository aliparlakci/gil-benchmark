# Multi-Language Threading Performance Benchmark

CPU-bound task execution comparing threading implementations across C, Go, and Python.

## Methodology

**Task**: Identical mathematical operations (280M floating-point calculations per run)
**Workload**: 20M iterations × 14 concurrent tasks
**Hardware**: 14 CPU cores
**Measurement**: 5 runs per configuration, statistical analysis

### Implementations

**C**: POSIX threads (pthread)
**Go**: Goroutines with runtime scheduler  
**Python**: Threading module + ProcessPoolExecutor

## Data

| Language | Single Thread  | Multi Thread  | Multi Process |
|----------|----------------|---------------|---------------|
| C        |  3.540±0.009s  |  0.329±0.014s | -             |
| Go       |  1.889±0.078s  |  0.195±0.005s | -             |
| Python   | 45.312±0.080s  | 45.48±0.1500s | 4.57±0.20s    |

## Results

**Threading Speedup (Multi-thread vs Single-thread):**
- C: 10.76x
- Go: 9.69x  
- Python: 0.99x

**Process Speedup (Multi-process vs Single-thread):**
- Python: 9.91x

## Analysis

Python threading shows 0.99x speedup, indicating serialized execution due to Global Interpreter Lock (GIL). C and Go threading achieve ~10x speedup, demonstrating parallel execution across CPU cores. Python multiprocessing achieves 9.91x speedup by bypassing GIL through separate processes.

**Note**: Execution times should not be compared across languages. This benchmark measures threading behavior within each language, not language performance.

## Usage

```bash
# Run all language benchmarks
./run_comparison.sh

# Or run individual languages
./run_c.sh 20000000 14
./run_go.sh 20000000 14
./run_python.sh 20000000 14
```

## Raw Output

```
Task Size: 20000000, Num Tasks: 14
C Single Thread:      3.541s 3.554s 3.528s 3.532s 3.546s | avg: 3.540±0.009s, min: 3.528s, max: 3.554s
C Multi Thread:       0.326s 0.327s 0.315s 0.355s 0.323s | avg: 0.329±0.014s, min: 0.315s, max: 0.355s
C Thread vs Single: 10.76x

Task Size: 20000000, Num Tasks: 14
Go Single Thread:     1.818s 1.963s 1.795s 1.992s 1.875s | avg: 1.889±0.078s, min: 1.795s, max: 1.992s
Go Multi Thread:      0.191s 0.187s 0.201s 0.200s 0.196s | avg: 0.195±0.005s, min: 0.187s, max: 0.201s
Go Goroutine vs Single: 9.69x

Task Size: 20000000, Num Tasks: 14
Python Single Thread: 45.442s 45.212s 45.357s 45.267s 45.281s | avg: 45.312±0.080s, min: 45.212s, max: 45.442s
Python Multi Thread:  45.722s 45.479s 45.644s 46.144s 45.500s | avg: 45.698±0.241s, min: 45.479s, max: 46.144s
Python Multi Process: 4.259s 4.440s 4.713s 4.778s 4.736s | avg: 4.585±0.202s, min: 4.259s, max: 4.778s
Python Thread vs Single:    0.99x
Python Process vs Single:  9.88x
```

## Files

**C Implementation:**
- `c_single.c` - C single-threaded baseline
- `c_multi.c` - C multi-threading with POSIX threads
- `run_c.sh` - C benchmark script

**Go Implementation:**
- `go_single.go` - Go single-threaded baseline
- `go_multi.go` - Go multi-threading with goroutines
- `run_go.sh` - Go benchmark script

**Python Implementation:**
- `single_thread.py` - Python single-threaded baseline
- `multi_thread.py` - Python multi-threading (GIL limited)
- `multi_process.py` - Python multi-processing (GIL bypass)
- `run_python.sh` - Python benchmark script

**Main Script:**
- `run_comparison.sh` - Runs all language benchmarks