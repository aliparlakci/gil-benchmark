# Python GIL vs Go Parallelism Benchmark

This benchmark compares Python's Global Interpreter Lock (GIL) limitations with Go's parallelism for CPU-bound tasks.

## What it tests

### Python (with GIL)
- **Single Thread**: Baseline performance (45.5s)
- **Multi Thread**: Multiple threads in one process - GIL prevents parallelism (45.6s)
- **Multi Process**: Multiple processes bypass GIL (4.6s)

### Go (no GIL)
- **Single Thread**: Baseline performance (1.9s)
- **Multi Thread**: Parallelism with goroutines (0.19s)

## Benchmark Results

**Task**: 20M iterations × 14 tasks on 14 CPU cores (5 runs each)

| Language | Single Thread | Multi Thread | Multi Process | Thread Speedup  |
|----------|---------------|--------------|---------------|-----------------|
| Python   | 45.5±0.4s     | 45.6±0.3s    | 4.6±0.2s      | 1.00x (no gain) |
| Go       | 1.9±0.0s      | 0.19±0.0s    | N/A*          | 10.1x speedup   |

*Go multi-process is N/A because Go's goroutines already achieve parallelism without the GIL limitation that Python has. Go's runtime scheduler automatically distributes goroutines across all available CPU cores within a single process, allowing each goroutine to run on separate cores simultaneously.

## Performance Summary

- **Go Multi vs Single**: 10.1x speedup - parallelism
- **Python Multi vs Single**: 1.0x - no speedup due to GIL
- **Python Process vs Single**: 9.9x speedup - bypasses GIL

## Usage

```bash
# Run full comparison (recommended)
./run_comparison.sh

# Or individually with custom parameters
python3 single_thread.py 20000000 14
go run go_single.go 20000000 14
```

## Key Insights

- **Python GIL**: Completely prevents CPU parallelism in threads
- **Python Workaround**: Multi-processing achieves ~10x speedup but with process overhead
- **Go Advantage**: Native goroutines achieve 10x parallelism with minimal overhead

## Files

- `single_thread.py` - Python single-threaded baseline
- `multi_thread.py` - Python multi-threading (GIL limited)
- `multi_process.py` - Python multi-processing (GIL bypass)
- `go_single.go` - Go single-threaded baseline
- `go_multi.go` - Go multi-threaded (parallelism)
- `run_comparison.sh` - Complete benchmark suite