#include <stdio.h>
#include <stdlib.h>

int n, q;
int *tree;

void build() {
    for (int i = n - 1; i > 0; i--) {
        tree[i] = tree[2 * i] + tree[2 * i + 1];
    }
}

int query(int l, int r) {
    int sum = 0;
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
    pos += n;
    tree[pos] = value;
    while (pos > 1) {
        pos >>= 1;
        tree[pos] = tree[2 * pos] + tree[2 * pos + 1];
    }
}

int main() {
    scanf("%d", &n);
    
    tree = (int*)malloc(2 * n * sizeof(int));
    
    for (int i = 0; i < n; i++) {
        scanf("%d", &tree[n + i]);
    }
    
    build();
    
    scanf("%d", &q);
    
    for (int i = 0; i < q; i++) {
        int l, r;
        scanf("%d %d", &l, &r);
        printf("%d ", query(l, r));
    }
    
    printf("\n");
    
    free(tree);
    return 0;
}
