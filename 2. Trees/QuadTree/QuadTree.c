#include <stdio.h>
#include <stdlib.h>
#include <limits.h>

#define MAXN 200

typedef struct Node {
    int x, y;
    struct Node *nw, *ne, *sw, *se;
} Node;

Node pool[MAXN];
int pc;

Node* new_node(int x, int y) {
    Node* n = &pool[pc++];
    n->x = x; n->y = y;
    n->nw = n->ne = n->sw = n->se = NULL;
    return n;
}

Node* insert(Node* t, int x, int y) {
    if (!t) return new_node(x, y);
    if (x < t->x && y >= t->y) t->nw = insert(t->nw, x, y);
    else if (x >= t->x && y >= t->y) t->ne = insert(t->ne, x, y);
    else if (x < t->x && y < t->y) t->sw = insert(t->sw, x, y);
    else t->se = insert(t->se, x, y);
    return t;
}

void print_tree(Node* t) {
    if (!t) return;
    printf("(%d,%d) ", t->x, t->y);
    print_tree(t->nw);
    print_tree(t->ne);
    print_tree(t->sw);
    print_tree(t->se);
}

int best_dist, bx, by;
void nearest(Node* t, int qx, int qy) {
    if (!t) return;
    int dx = t->x - qx, dy = t->y - qy, d = dx*dx + dy*dy;
    if (d < best_dist) { best_dist = d; bx = t->x; by = t->y; }
    nearest(t->nw, qx, qy);
    nearest(t->ne, qx, qy);
    nearest(t->sw, qx, qy);
    nearest(t->se, qx, qy);
}

int main(void) {
    int n, x, y, qx, qy;
    if (scanf("%d", &n) != 1) return 1;
    Node* root = NULL;
    for (int i = 0; i < n; i++) {
        scanf("%d%d", &x, &y);
        root = insert(root, x, y);
    }
    printf("Points: ");
    print_tree(root);
    printf("\n");
    scanf("%d%d", &qx, &qy);
    best_dist = INT_MAX;
    nearest(root, qx, qy);
    printf("Nearest to (%d,%d): (%d,%d)\n", qx, qy, bx, by);
    return 0;
}
