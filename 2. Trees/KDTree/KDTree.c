#include <stdio.h>
#include <stdlib.h>

#define MAXN 100

typedef struct Node {
    int x, y;
    struct Node *l, *r;
} Node;

Node pool[MAXN];
int pc;

Node* new_node(int x, int y) {
    Node* n = &pool[pc++];
    n->x = x; n->y = y;
    n->l = n->r = NULL;
    return n;
}

Node* insert(Node* t, int x, int y, int d) {
    if (!t) return new_node(x, y);
    if (((d&1)? y - t->y : x - t->x) < 0)
        t->l = insert(t->l, x, y, d+1);
    else
        t->r = insert(t->r, x, y, d+1);
    return t;
}

void print_inorder(Node* t) {
    if (!t) return;
    print_inorder(t->l);
    printf("(%d,%d) ", t->x, t->y);
    print_inorder(t->r);
}

int best_dist, bx, by;
void nearest(Node* t, int qx, int qy) {
    if (!t) return;
    int dx = t->x - qx, dy = t->y - qy;
    int d = dx*dx + dy*dy;
    if (d < best_dist) {
        best_dist = d; bx = t->x; by = t->y;
    }
    nearest(t->l, qx, qy);
    nearest(t->r, qx, qy);
}

int main(void) {
    int n, x, y, qx, qy;
    if (scanf("%d", &n) != 1) return 1;
    Node* root = NULL;
    for (int i = 0; i < n; i++) {
        scanf("%d %d", &x, &y);
        root = insert(root, x, y, 0);
    }
    print_inorder(root);
    putchar('\n');
    scanf("%d %d", &qx, &qy);
    best_dist = 1<<30;
    nearest(root, qx, qy);
    printf("Nearest to (%d,%d): (%d,%d)\n", qx, qy, bx, by);
    return 0;
}
