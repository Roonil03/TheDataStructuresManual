#include <stdio.h>
#include <stdlib.h>

#define MAXN 400

static int heap[MAXN];
static int heap_size = 0;

/* Insert value into max-heap */
void insert_heap(int value) {
    int i = heap_size++;
    while (i > 0) {
        int parent = (i - 1) / 2;
        if (heap[parent] >= value) break;
        heap[i]      = heap[parent];
        i            = parent;
    }
    heap[i] = value;
}

/* Extract and return the maximum value from max-heap */
int extract_max(void) {
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
    if (scanf("%d", &n) != 1) return EXIT_FAILURE;
    for (int i = 0; i < n; i++) {
        scanf("%d", &x);
        insert_heap(x);
    }
    for (int i = 0; i < n; i++) {
        printf("%d ", extract_max());
    }
    putchar('\n');
    return 0;
}
