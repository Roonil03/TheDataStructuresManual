#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <assert.h>
#include <string.h>

/* Node and heap definitions */
typedef struct Node {
    int key, degree;
    int mark;
    struct Node *parent, *child, *left, *right;
} Node;

typedef struct {
    Node *min;
    int n;
} FibHeap;

/* Create a new node */
Node* make_node(int k) {
    Node *x = malloc(sizeof(*x));
    x->key = k; x->degree = 0; x->mark = 0;
    x->parent = x->child = NULL;
    x->left = x->right = x;
    return x;
}

/* Initialize empty heap */
FibHeap* make_heap() {
    FibHeap *H = malloc(sizeof(*H));
    H->min = NULL; H->n = 0;
    return H;
}

/* Insert node into root list */
void fib_insert(FibHeap *H, Node *x) {
    if (!H->min) {
        H->min = x;
    } else {
        /* link into root list */
        x->left = H->min; x->right = H->min->right;
        H->min->right->left = x; H->min->right = x;
        if (x->key < H->min->key)
            H->min = x;
    }
    H->n++;
}

/* Link two trees of same degree */
void fib_link(FibHeap *H, Node *y, Node *x) {
    /* remove y from root list */
    y->left->right = y->right; y->right->left = y->left;
    y->parent = x;
    if (!x->child)
        x->child = y, y->left = y->right = y;
    else {
        y->left = x->child; y->right = x->child->right;
        x->child->right->left = y; x->child->right = y;
    }
    x->degree++;
    y->mark = 0;
}

/* Consolidate roots after extract-min */
void fib_consolidate(FibHeap *H) {
    int D = 1;
    while ((1 << D) <= H->n) D++;
    Node **A = calloc(D+1, sizeof(Node*));
    Node *w = H->min;
    if (!w) { free(A); return; }
    /* gather roots */
    int cnt = 0;
    Node *start = w;
    do { cnt++; w = w->right; } while (w != start);
    while (cnt--) {
        Node *x = start; start = start->right;
        int d = x->degree;
        while (A[d]) {
            Node *y = A[d];
            if (x->key > y->key) { Node *t=x; x=y; y=t; }
            fib_link(H, y, x);
            A[d++] = NULL;
        }
        A[d] = x;
    }
    H->min = NULL;
    for (int i = 0; i <= D; i++) {
        if (A[i]) {
            if (!H->min) {
                H->min = A[i]->left = A[i]->right = A[i];
            } else {
                /* reinsert A[i] into root list */
                Node *x = A[i];
                x->left = H->min; x->right = H->min->right;
                H->min->right->left = x; H->min->right = x;
                if (x->key < H->min->key)
                    H->min = x;
            }
        }
    }
    free(A);
}

/* Extract and return minimum key */
int fib_extract_min(FibHeap *H) {
    Node *z = H->min;
    if (!z) return INT_MIN;
    /* add children to root list */
    if (z->child) {
        Node *c = z->child;
        do {
            Node *n = c->right;
            /* add c to root list */
            c->left->right = c->right; c->right->left = c->left;
            c->left = H->min; c->right = H->min->right;
            H->min->right->left = c; H->min->right = c;
            c->parent = NULL;
            c = n;
        } while (c != z->child);
    }
    /* remove z */
    z->left->right = z->right; z->right->left = z->left;
    if (z == z->right) H->min = NULL;
    else {
        H->min = z->right;
        fib_consolidate(H);
    }
    H->n--;
    int key = z->key;
    free(z);
    return key;
}

/* Cut x from its parent y */
void fib_cut(FibHeap *H, Node *x, Node *y) {
    /* remove x */
    if (x->right == x) y->child = NULL;
    else {
        x->left->right = x->right; x->right->left = x->left;
        if (y->child == x) y->child = x->right;
    }
    y->degree--;
    /* add x to root list */
    x->left = H->min; x->right = H->min->right;
    H->min->right->left = x; H->min->right = x;
    x->parent = NULL; x->mark = 0;
}

/* Cascading cut */
void fib_cascading_cut(FibHeap *H, Node *y) {
    Node *z = y->parent;
    if (z) {
        if (!y->mark) y->mark = 1;
        else {
            fib_cut(H, y, z);
            fib_cascading_cut(H, z);
        }
    }
}

/* Decrease key of node x to k */
void fib_decrease_key(FibHeap *H, Node *x, int k) {
    assert(x->key >= k);
    x->key = k;
    Node *y = x->parent;
    if (y && x->key < y->key) {
        fib_cut(H, x, y);
        fib_cascading_cut(H, y);
    }
    if (x->key < H->min->key)
        H->min = x;
}

/* Delete node x */
void fib_delete(FibHeap *H, Node *x) {
    fib_decrease_key(H, x, INT_MIN);
    fib_extract_min(H);
}

/* Sample driver: reads commands newline-separated, echoes output */
int main() {
    FibHeap *H = make_heap();
    char cmd[16];
    while (scanf("%s", cmd) == 1) {
        if (strcmp(cmd, "insert") == 0) {
            int k; scanf("%d", &k);
            fib_insert(H, make_node(k));
        } else if (strcmp(cmd, "find_min") == 0) {
            if (H->min) printf("%d\n", H->min->key);
            else printf("empty\n");
        } else if (strcmp(cmd, "extract_min") == 0) {
            int m = fib_extract_min(H);
            if (m==INT_MIN) printf("empty\n"); else printf("%d\n", m);
        } else if (strcmp(cmd, "exit") == 0) {
            break;
        }
    }
    return 0;
}
