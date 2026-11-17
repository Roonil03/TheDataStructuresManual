#include "../../common/input.h"
/* Alternating-axis point insertion with exhaustive nearest search. */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define MAXN 100

typedef struct Node {
    int x, y;
    struct Node *l, *r;
} Node;

Node pool[MAXN];
int pc;

Node* new_node(int x, int y) {
    if (pc >= MAXN) exit(EXIT_FAILURE);
    Node* n = &pool[pc++];
    n->x = x; n->y = y;
    n->l = n->r = NULL;
    return n;
}

Node* insert(Node* t, int x, int y, int d) {
    if (!t) return new_node(x, y);
    if (((d & 1) ? y < t->y : x < t->x))
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
        (d.carry == best_dist.carry && d.low < best_dist.low)) {
        best_dist = d; bx = t->x; by = t->y;
    }
    nearest(t->l, qx, qy);
    nearest(t->r, qx, qy);
}

int main(void) {
    int n, x, y, qx, qy;
    if (!readInteger(&n) || n < 1 || n > MAXN) return EXIT_FAILURE;
    Node* root = NULL;
    for (int i = 0; i < n; i++) {
        if (!readInteger(&x) || !readInteger(&y)) return EXIT_FAILURE;
        root = insert(root, x, y, 0);
    }
    print_inorder(root);
    putchar('\n');
    if (!readInteger(&qx) || !readInteger(&qy)) return EXIT_FAILURE;
    best_dist = (Distance){UINT64_MAX, 2};
    nearest(root, qx, qy);
    printf("Nearest to (%d,%d): (%d,%d)\n", qx, qy, bx, by);
    return 0;
}
