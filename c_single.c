#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

double cpu_bound_task(int n) {
    double total = 0.0;
    for (int i = 0; i < n; i++) {
        double fi = (double)i;
        total += fi * fi;
        total += sqrt(fi);
        total += fi * 3.14159;
        total += fabs(fi - 1000);
        total += (double)((int)(fi / 2));
        total += sin(fi);
        total += cos(fi);
    }
    return total;
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("Usage: %s <task_size> <num_tasks>\n", argv[0]);
        return 1;
    }
    
    int task_size = atoi(argv[1]);
    int num_tasks = atoi(argv[2]);
    
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);
    
    for (int i = 0; i < num_tasks; i++) {
        cpu_bound_task(task_size);
    }
    
    clock_gettime(CLOCK_MONOTONIC, &end);
    
    long long nanoseconds = (end.tv_sec - start.tv_sec) * 1000000000LL + 
                           (end.tv_nsec - start.tv_nsec);
    
    printf("%lld\n", nanoseconds);
    return 0;
}