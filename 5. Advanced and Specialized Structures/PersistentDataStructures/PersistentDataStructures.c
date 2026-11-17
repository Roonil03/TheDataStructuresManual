#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <stdint.h>

static void *checked_alloc(size_t size) {
    void *p = malloc(size);
    if (!p) {
        fputs("Allocation failed\n", stderr);
        exit(EXIT_FAILURE);
    }
    return p;
}

/* Versions share immutable tails; only push versions own their new top node. */
typedef struct PNode {
    int value;
    struct PNode *next;
} PNode;

typedef struct {
    PNode *top;
    int size;
    int owns_top;
} PStack;

typedef struct {
    PStack *versions;
    int num_versions;
    int cap;
} PersistentStack;

PersistentStack *pstack_create(void) {
    PersistentStack *ps = checked_alloc(sizeof(PersistentStack));
    ps->cap = 16;
    ps->versions = checked_alloc(ps->cap * sizeof(PStack));
    ps->versions[0].top = NULL;
    ps->versions[0].size = 0;
    ps->versions[0].owns_top = 0;
    ps->num_versions = 1;
    return ps;
}

static void ensure_capacity(PersistentStack *ps) {
    if (ps->num_versions == ps->cap) {
        if (ps->cap > INT_MAX / 2 || (size_t)ps->cap * 2 > SIZE_MAX / sizeof(PStack)) {
            fputs("Version capacity exceeded\n", stderr);
            exit(EXIT_FAILURE);
        }
        int new_cap = ps->cap * 2;
        PStack *versions = realloc(ps->versions, (size_t)new_cap * sizeof(PStack));
        if (!versions) {
            fputs("Allocation failed\n", stderr);
            exit(EXIT_FAILURE);
        }
        ps->versions = versions;
        ps->cap = new_cap;
    }
}

int pstack_push(PersistentStack *ps, int version, int value) {
    if (!ps || version < 0 || version >= ps->num_versions) return -1;
    ensure_capacity(ps);

    PNode *node = checked_alloc(sizeof(PNode));
    node->value = value;
    node->next = ps->versions[version].top;

    int new_ver = ps->num_versions;
    ps->versions[new_ver].top = node;
    ps->versions[new_ver].size = ps->versions[version].size + 1;
    ps->versions[new_ver].owns_top = 1;
    ps->num_versions++;
    return new_ver;
}

int pstack_pop(PersistentStack *ps, int version, int *out_value) {
    if (!ps || version < 0 || version >= ps->num_versions) return -1;
    if (!ps->versions[version].top || !out_value) return -1;
    ensure_capacity(ps);

    *out_value = ps->versions[version].top->value;

    int new_ver = ps->num_versions;
    ps->versions[new_ver].top = ps->versions[version].top->next;
    ps->versions[new_ver].size = ps->versions[version].size - 1;
    ps->versions[new_ver].owns_top = 0;
    ps->num_versions++;
    return new_ver;
}

int pstack_peek(PersistentStack *ps, int version) {
    if (!ps || version < 0 || version >= ps->num_versions) return -1;
    if (!ps->versions[version].top) return -1;
    return ps->versions[version].top->value;
}

int pstack_size(PersistentStack *ps, int version) {
    if (!ps || version < 0 || version >= ps->num_versions) return -1;
    return ps->versions[version].size;
}

void pstack_print_version(PersistentStack *ps, int version) {
    if (!ps || version < 0 || version >= ps->num_versions) return;
    printf("  v%d (size=%d):", version, ps->versions[version].size);
    for (PNode *n = ps->versions[version].top; n; n = n->next)
        printf(" %d", n->value);
    printf("\n");
}

void pstack_print_all(PersistentStack *ps) {
    printf("PersistentStack (%d versions):\n", ps->num_versions);
    for (int i = 0; i < ps->num_versions; i++)
        pstack_print_version(ps, i);
}

void pstack_free(PersistentStack *ps) {
    if (!ps) return;
    for (int i = 0; i < ps->num_versions; i++)
        if (ps->versions[i].owns_top) free(ps->versions[i].top);
    free(ps->versions);
    free(ps);
}

int main(void) {
    PersistentStack *ps = pstack_create();

    int v1 = pstack_push(ps, 0, 10);
    int v2 = pstack_push(ps, v1, 20);
    int v3 = pstack_push(ps, v2, 30);

    printf("After pushes 10, 20, 30:\n");
    pstack_print_all(ps);

    int v4 = pstack_push(ps, v1, 99);

    printf("\nBranched from v%d, pushed 99:\n", v1);
    pstack_print_version(ps, v4);

    int popped;
    int v5 = pstack_pop(ps, v3, &popped);
    printf("\nPopped from v%d: %d\n", v3, popped);
    pstack_print_version(ps, v5);

    printf("\nOriginal v%d still intact:\n", v3);
    pstack_print_version(ps, v3);

    printf("\nv%d peek: %d\n", v2, pstack_peek(ps, v2));
    printf("v%d size: %d\n", v3, pstack_size(ps, v3));
    printf("v%d size: %d\n", v4, pstack_size(ps, v4));

    printf("\nFull version history:\n");
    pstack_print_all(ps);

    pstack_free(ps);
    printf("Demonstration complete.\n");
    return 0;
}
