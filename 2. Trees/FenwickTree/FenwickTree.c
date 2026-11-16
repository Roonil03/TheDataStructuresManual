/* Array-backed prefix sums with point-add updates. */
#include <stdio.h>
#include <stdlib.h>
#include <limits.h>

int n, q;
long long *tree;

void update(int idx, int val) {
    if (idx < 0 || idx >= n) return;
    for (idx++; idx <= n; idx += idx & -idx) {
        tree[idx] += val;
    }
}

long long query(int idx) {
    long long sum = 0;
    if (idx < 0 || idx >= n) return 0;
    for (idx++; idx > 0; idx -= idx & -idx) {
        sum += tree[idx];
    }
    return sum;
}

int main() {
    if (scanf("%d", &n) != 1 || n < 0 || n > INT_MAX / 2) return EXIT_FAILURE;

    tree = (long long*)calloc(n + 1, sizeof(long long));
    if (!tree && n != 0) exit(EXIT_FAILURE);

    for (int i = 0; i < n; i++) {
        int val;
        if (scanf("%d", &val) != 1) { free(tree); return EXIT_FAILURE; }
        update(i, val);
    }

    if (scanf("%d", &q) != 1 || q < 0) { free(tree); return EXIT_FAILURE; }

    for (int i = 0; i < q; i++) {
        int idx;
        if (scanf("%d", &idx) != 1 || idx < 0 || idx >= n) { free(tree); return EXIT_FAILURE; }
        printf("%lld ", query(idx));
    }

    printf("\n");

    free(tree);
    return 0;
}
