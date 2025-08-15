#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <pthread.h>

typedef struct {
    int task_size;
    int thread_id;
    double result;
} thread_data_t;

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

void* thread_worker(void* arg) {
    thread_data_t* data = (thread_data_t*)arg;
    data->result = cpu_bound_task(data->task_size);
    return NULL;
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("Usage: %s <task_size> <num_tasks>\n", argv[0]);
        return 1;
    }
    
    int task_size = atoi(argv[1]);
    int num_tasks = atoi(argv[2]);
    
    pthread_t* threads = malloc(num_tasks * sizeof(pthread_t));
    thread_data_t* thread_data = malloc(num_tasks * sizeof(thread_data_t));
    
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);
    
    // Create threads
    for (int i = 0; i < num_tasks; i++) {
        thread_data[i].task_size = task_size;
        thread_data[i].thread_id = i;
        pthread_create(&threads[i], NULL, thread_worker, &thread_data[i]);
    }
    
    // Wait for threads to complete
    for (int i = 0; i < num_tasks; i++) {
        pthread_join(threads[i], NULL);
    }
    
    clock_gettime(CLOCK_MONOTONIC, &end);
    
    long long nanoseconds = (end.tv_sec - start.tv_sec) * 1000000000LL + 
                           (end.tv_nsec - start.tv_nsec);
    
    printf("%lld\n", nanoseconds);
    
    free(threads);
    free(thread_data);
    return 0;
}