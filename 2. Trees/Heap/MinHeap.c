#include <stdio.h>
#include <stdlib.h>

#define MAX_SIZE 1000

typedef struct {
    int data[MAX_SIZE];
    int size;
} MinHeap;

MinHeap heap = {0};

void swap(int *a, int *b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

void heapify_up(int index) {
    if (index == 0) return;
    
    int parent = (index - 1) / 2;
    if (heap.data[index] < heap.data[parent]) {
        swap(&heap.data[index], &heap.data[parent]);
        heapify_up(parent);
    }
}

void heapify_down(int index) {
    int left = 2 * index + 1;
    int right = 2 * index + 2;
    int smallest = index;
    
    if (left < heap.size && heap.data[left] < heap.data[smallest]) {
        smallest = left;
    }
    
    if (right < heap.size && heap.data[right] < heap.data[smallest]) {
        smallest = right;
    }
    
    if (smallest != index) {
        swap(&heap.data[index], &heap.data[smallest]);
        heapify_down(smallest);
    }
}

void insert(int value) {
    heap.data[heap.size] = value;
    heapify_up(heap.size);
    heap.size++;
}

int extract_min() {
    if (heap.size == 0) return -1;
    
    int min = heap.data[0];
    heap.data[0] = heap.data[heap.size - 1];
    heap.size--;
    
    if (heap.size > 0) {
        heapify_down(0);
    }
    
    return min;
}

int main() {
    int n, value;
    
    scanf("%d", &n);
    
    for (int i = 0; i < n; i++) {
        scanf("%d", &value);
        insert(value);
    }
    
    for (int i = 0; i < n; i++) {
        printf("%d ", extract_min());
    }
    
    printf("\n");
    return 0;
}
