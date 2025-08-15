package main

import (
	"fmt"
	"math"
	"os"
	"strconv"
	"time"
)

func cpuBoundTask(n int) float64 {
	total := 0.0
	for i := 0; i < n; i++ {
		fi := float64(i)
		total += fi * fi
		total += math.Sqrt(fi)
		total += fi * 3.14159
		total += math.Abs(fi - 1000)
		total += float64(int(fi / 2))
		total += math.Sin(fi)
		total += math.Cos(fi)
	}
	return total
}

func main() {
	taskSize, _ := strconv.Atoi(os.Args[1])
	numTasks, _ := strconv.Atoi(os.Args[2])
	
	start := time.Now()
	results := make([]float64, numTasks)
	for i := 0; i < numTasks; i++ {
		results[i] = cpuBoundTask(taskSize)
	}
	duration := time.Since(start)
	
	fmt.Println(duration.Nanoseconds())
}