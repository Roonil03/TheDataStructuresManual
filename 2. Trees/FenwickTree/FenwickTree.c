#include <stdio.h>
#include <stdlib.h>

int n, q;
int *tree;

void update(int idx, int val) {
    for (idx++; idx <= n; idx += idx & -idx) {
        tree[idx] += val;
    }
}

int query(int idx) {
    int sum = 0;
    for (idx++; idx > 0; idx -= idx & -idx) {
        sum += tree[idx];
    }
    return sum;
}

int main() {
    scanf("%d", &n);
    
    tree = (int*)calloc(n + 1, sizeof(int));
    
    for (int i = 0; i < n; i++) {
        int val;
        scanf("%d", &val);
        update(i, val);
    }
    
    scanf("%d", &q);
    
    for (int i = 0; i < q; i++) {
        int idx;
        scanf("%d", &idx);
        printf("%d ", query(idx));
    }
    
    printf("\n");
    
    free(tree);
    return 0;
}
