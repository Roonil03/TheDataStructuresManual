/* Iterative range sums with leaves in the second half of the array. */
#include <stdio.h>
#include <stdlib.h>
#include <limits.h>

int n, q;
long long *tree;

void build() {
    for (int i = n - 1; i > 0; i--) {
        tree[i] = tree[2 * i] + tree[2 * i + 1];
    }
}

long long query(int l, int r) {
    long long sum = 0;
    l += n;
    r += n + 1;
    while (l < r) {
        if (l & 1) sum += tree[l++];
        if (r & 1) sum += tree[--r];
        l >>= 1;
        r >>= 1;
    }
    return sum;
}

void update(int pos, int value) {
    if (pos < 0 || pos >= n) return;
    pos += n;
    tree[pos] = value;
    while (pos > 1) {
        pos >>= 1;
        tree[pos] = tree[2 * pos] + tree[2 * pos + 1];
    }
}

int main() {
    if (scanf("%d", &n) != 1 || n < 0 || n > INT_MAX / 2) return EXIT_FAILURE;

    tree = (long long*)malloc(2 * n * sizeof(long long));
    if (!tree && n != 0) exit(EXIT_FAILURE);

    for (int i = 0; i < n; i++) {
        if (scanf("%lld", &tree[n + i]) != 1 || tree[n + i] < INT_MIN || tree[n + i] > INT_MAX) { free(tree); return EXIT_FAILURE; }
    }

    build();

    if (scanf("%d", &q) != 1 || q < 0) { free(tree); return EXIT_FAILURE; }

    for (int i = 0; i < q; i++) {
        int l, r;
        if (scanf("%d %d", &l, &r) != 2 || l < 0 || l > r || r >= n) { free(tree); return EXIT_FAILURE; }
        printf("%lld ", query(l, r));
    }

    printf("\n");

    free(tree);
    return 0;
}
