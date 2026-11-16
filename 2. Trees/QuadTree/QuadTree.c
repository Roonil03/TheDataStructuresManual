/* Point-quadtree insertion with exhaustive nearest search. */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <limits.h>

#define MAXN 200

typedef struct Node {
    int x, y;
    struct Node *nw, *ne, *sw, *se;
} Node;

Node pool[MAXN];
int pc;

Node* new_node(int x, int y) {
    if (pc >= MAXN) exit(EXIT_FAILURE);
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

typedef struct {
    uint64_t low;
    unsigned carry;
} Distance;

Distance best_dist;
int bx, by;

Distance squared_distance(int x, int y, int qx, int qy) {
    int64_t dx = (int64_t)x - qx, dy = (int64_t)y - qy;
    uint64_t ax = (uint64_t)(dx < 0 ? -dx : dx);
    uint64_t ay = (uint64_t)(dy < 0 ? -dy : dy);
    uint64_t xx = ax * ax, yy = ay * ay;
    Distance result = {xx + yy, xx + yy < xx};
    return result;
}

void nearest(Node* t, int qx, int qy) {
    if (!t) return;
    Distance d = squared_distance(t->x, t->y, qx, qy);
    if (d.carry < best_dist.carry ||
        (d.carry == best_dist.carry && d.low < best_dist.low)) { best_dist = d; bx = t->x; by = t->y; }
    nearest(t->nw, qx, qy);
    nearest(t->ne, qx, qy);
    nearest(t->sw, qx, qy);
    nearest(t->se, qx, qy);
}

int main(void) {
    int n, x, y, qx, qy;
    if (scanf("%d", &n) != 1 || n < 1 || n > MAXN) return EXIT_FAILURE;
    Node* root = NULL;
    for (int i = 0; i < n; i++) {
        if (scanf("%d%d", &x, &y) != 2) return EXIT_FAILURE;
        root = insert(root, x, y);
    }
    printf("Points: ");
    print_tree(root);
    printf("\n");
    if (scanf("%d%d", &qx, &qy) != 2) return EXIT_FAILURE;
    best_dist = (Distance){UINT64_MAX, 2};
    nearest(root, qx, qy);
    printf("Nearest to (%d,%d): (%d,%d)\n", qx, qy, bx, by);
    return 0;
}
