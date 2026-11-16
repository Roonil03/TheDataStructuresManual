#include "../../common/input.h"
/* Array-backed heap insertion and repeated root extraction. */
#include <stdio.h>
#include <stdlib.h>

#define MAXN 400

static int heap[MAXN];
static int heap_size = 0;

void insert_heap(int value) {
    if (heap_size >= MAXN) exit(EXIT_FAILURE);
    int i = heap_size++;
    while (i > 0) {
        int parent = (i - 1) / 2;
        if (heap[parent] >= value) break;
        heap[i]      = heap[parent];
        i            = parent;
    }
    heap[i] = value;
}

int extract_max(void) {
    if (heap_size == 0) exit(EXIT_FAILURE);
    int result = heap[0];
    int last   = heap[--heap_size];
    int i      = 0;
    while (2 * i + 1 < heap_size) {
        int child = 2 * i + 1;
        if (child + 1 < heap_size && heap[child + 1] > heap[child]) {
            child++;
        }
        if (last >= heap[child]) break;
        heap[i] = heap[child];
        i       = child;
    }
    heap[i] = last;
    return result;
}

int main(void) {
    int n, x;
    if (!readInteger(&n) || n < 0 || n > MAXN) return EXIT_FAILURE;
    for (int i = 0; i < n; i++) {
        if (!readInteger(&x)) return EXIT_FAILURE;
        insert_heap(x);
    }
    for (int i = 0; i < n; i++) {
        printf("%d ", extract_max());
    }
    putchar('\n');
    return 0;
}
