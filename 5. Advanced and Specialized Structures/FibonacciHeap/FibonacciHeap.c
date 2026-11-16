#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <string.h>

static void *checked_alloc(size_t size) {
    void *p = malloc(size);
    if (!p) {
        fputs("Allocation failed\n", stderr);
        exit(EXIT_FAILURE);
    }
    return p;
}

/* Heap-ordered trees form circular sibling lists; marked nodes drive cascading cuts. */
typedef struct Node {
    int key, degree;
    int mark;
    struct Node *parent, *child, *left, *right;
} Node;

typedef struct {
    Node *min;
    int n;
} FibHeap;

Node* make_node(int k) {
    Node *x = checked_alloc(sizeof(*x));
    x->key = k; x->degree = 0; x->mark = 0;
    x->parent = x->child = NULL;
    x->left = x->right = x;
    return x;
}

FibHeap* make_heap(void) {
    FibHeap *H = checked_alloc(sizeof(*H));
    H->min = NULL; H->n = 0;
    return H;
}

void fib_insert(FibHeap *H, Node *x) {
    if (H->n == INT_MAX) {
        fputs("Heap capacity exceeded\n", stderr);
        exit(EXIT_FAILURE);
    }
    if (!H->min) {
        H->min = x;
    } else {
        x->left = H->min; x->right = H->min->right;
        H->min->right->left = x; H->min->right = x;
        if (x->key < H->min->key)
            H->min = x;
    }
    H->n++;
}

void fib_link(Node *y, Node *x) {
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

void fib_consolidate(FibHeap *H) {
    enum { DEGREE_LIMIT = 2 * sizeof(unsigned int) * CHAR_BIT + 1 };
    Node *A[DEGREE_LIMIT] = {NULL};
    Node *w = H->min;
    if (!w) return;
    int cnt = 0;
    Node *start = w;
    do { cnt++; w = w->right; } while (w != start);
    while (cnt--) {
        Node *x = start; start = start->right;
        int d = x->degree;
        while (A[d]) {
            Node *y = A[d];
            if (x->key > y->key) { Node *t=x; x=y; y=t; }
            fib_link(y, x);
            A[d++] = NULL;
        }
        A[d] = x;
    }
    H->min = NULL;
    for (int i = 0; i < DEGREE_LIMIT; i++) {
        if (A[i]) {
            if (!H->min) {
                H->min = A[i]->left = A[i]->right = A[i];
            } else {
                Node *x = A[i];
                x->left = H->min; x->right = H->min->right;
                H->min->right->left = x; H->min->right = x;
                if (x->key < H->min->key)
                    H->min = x;
            }
        }
    }
}

int fib_extract_min(FibHeap *H) {
    Node *z = H->min;
    if (!z) return INT_MIN;
    if (z->child) {
        Node *c = z->child;
        int children = z->degree;
        while (children--) {
            Node *n = c->right;
            c->left->right = c->right; c->right->left = c->left;
            c->left = H->min; c->right = H->min->right;
            H->min->right->left = c; H->min->right = c;
            c->parent = NULL;
            c->mark = 0;
            c = n;
        }
    }
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

void fib_cut(FibHeap *H, Node *x, Node *y) {
    if (x->right == x) y->child = NULL;
    else {
        x->left->right = x->right; x->right->left = x->left;
        if (y->child == x) y->child = x->right;
    }
    y->degree--;
    x->left = H->min; x->right = H->min->right;
    H->min->right->left = x; H->min->right = x;
    x->parent = NULL; x->mark = 0;
}

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

void fib_decrease_key(FibHeap *H, Node *x, int k) {
    if (!H || !H->min || !x || k > x->key) return;
    x->key = k;
    Node *y = x->parent;
    if (y && x->key < y->key) {
        fib_cut(H, x, y);
        fib_cascading_cut(H, y);
    }
    if (x->key < H->min->key)
        H->min = x;
}

void fib_delete(FibHeap *H, Node *x) {
    if (!H || !H->min || !x) return;
    Node *parent = x->parent;
    if (parent) {
        fib_cut(H, x, parent);
        fib_cascading_cut(H, parent);
    }
    H->min = x;
    fib_extract_min(H);
}

int main(void) {
    FibHeap *H = make_heap();
    char cmd[16];
    while (scanf("%15s", cmd) == 1) {
        if (strcmp(cmd, "insert") == 0) {
            int k;
            if (scanf("%d", &k) != 1) break;
            fib_insert(H, make_node(k));
        } else if (strcmp(cmd, "find_min") == 0) {
            if (H->min) printf("%d\n", H->min->key);
            else printf("empty\n");
        } else if (strcmp(cmd, "extract_min") == 0) {
            if (!H->min) printf("empty\n");
            else printf("%d\n", fib_extract_min(H));
        } else if (strcmp(cmd, "exit") == 0) {
            break;
        }
    }
    while (H->min) fib_extract_min(H);
    free(H);
    return 0;
}
