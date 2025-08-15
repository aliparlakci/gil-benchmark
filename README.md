# Python GIL vs Go Parallelism Benchmark

This benchmark compares Python's Global Interpreter Lock (GIL) limitations with Go's parallelism for CPU-bound tasks.

## What it tests

### Python (with GIL)
- **Single Thread**: Baseline performance (45.3s)
- **Multi Thread**: Multiple threads in one process - GIL prevents parallelism (45.5s)
- **Multi Process**: Multiple processes bypass GIL (4.6s)

### Go (no GIL)
- **Single Thread**: Baseline performance (1.9s)
- **Multi Thread**: Parallelism with goroutines (0.18s)

## Benchmark Results

**Task**: 20M iterations × 14 tasks on 14 CPU cores (5 runs each)

| Language | Single Thread | Multi Thread | Multi Process |
|----------|---------------|--------------|---------------|
| Python   | 45.3±0.1s     | 45.5±0.1s    | 4.6±0.2s      |
| Go       | 1.9±0.2s      | 0.18±0.01s   | N/A*          |

*Go multi-process is N/A because Go's goroutines already achieve parallelism without the GIL limitation that Python has. Go's runtime scheduler automatically distributes goroutines across all available CPU cores within a single process, allowing each goroutine to run on separate cores simultaneously.

## Performance Summary

- **Go Multi vs Single**: 10.5x speedup
- **Python Multi vs Single**: 0.99x (slower due to GIL)
- **Python Process vs Single**: 9.9x speedup

## Key Insights

- **Python GIL**: Completely prevents CPU parallelism in threads
- **Python Workaround**: Multi-processing achieves ~10x speedup but with process overhead
- **Go Advantage**: Native goroutines achieve 10.5x parallelism with minimal overhead

## Usage

```bash
# Run full comparison (recommended)
./run_comparison.sh

# Or individually with custom parameters
python3 single_thread.py 20000000 14
go run go_single.go 20000000 14
```

## Raw Output

```
Python GIL vs Go Benchmark Results (5 runs each)
Task Size: 20000000, Num Tasks: 14
================================================

Go Single Thread:     2.149s 1.903s 1.844s 2.089s 1.743s | avg: 1.946±0.152s, min: 1.743s, max: 2.149s
Go Multi Thread:      0.197s 0.177s 0.184s 0.190s 0.178s | avg: 0.185±0.008s, min: 0.177s, max: 0.197s
Python Single Thread: 45.060s 45.267s 45.442s 45.242s 45.245s | avg: 45.251±0.121s, min: 45.060s, max: 45.442s
Python Multi Thread:  45.522s 45.580s 45.611s 45.501s 45.193s | avg: 45.482±0.149s, min: 45.193s, max: 45.611s
Python Multi Process: 4.228s 4.674s 4.485s 4.786s 4.666s | avg: 4.568±0.195s, min: 4.228s, max: 4.786s
Go Multi vs Single:        10.50x speedup
Python Multi vs Single:    0.99x (slower due to GIL)
Python Process vs Single:  9.91x speedup
```
