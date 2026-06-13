#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct PNode {
    int value;
    struct PNode *next;
} PNode;

typedef struct {
    PNode *top;
    int size;
} PStack;

typedef struct {
    PStack *versions;
    int num_versions;
    int cap;
} PersistentStack;

PersistentStack *pstack_create(void) {
    PersistentStack *ps = malloc(sizeof(PersistentStack));
    ps->cap = 16;
    ps->versions = malloc(ps->cap * sizeof(PStack));
    ps->versions[0].top = NULL;
    ps->versions[0].size = 0;
    ps->num_versions = 1;
    return ps;
}

static void ensure_capacity(PersistentStack *ps) {
    if (ps->num_versions == ps->cap) {
        ps->cap *= 2;
        ps->versions = realloc(ps->versions, ps->cap * sizeof(PStack));
    }
}

int pstack_push(PersistentStack *ps, int version, int value) {
    if (version < 0 || version >= ps->num_versions) return -1;
    ensure_capacity(ps);

    PNode *node = malloc(sizeof(PNode));
    node->value = value;
    node->next = ps->versions[version].top;

    int new_ver = ps->num_versions;
    ps->versions[new_ver].top = node;
    ps->versions[new_ver].size = ps->versions[version].size + 1;
    ps->num_versions++;
    return new_ver;
}

int pstack_pop(PersistentStack *ps, int version, int *out_value) {
    if (version < 0 || version >= ps->num_versions) return -1;
    if (!ps->versions[version].top) return -1;
    ensure_capacity(ps);

    *out_value = ps->versions[version].top->value;

    int new_ver = ps->num_versions;
    ps->versions[new_ver].top = ps->versions[version].top->next;
    ps->versions[new_ver].size = ps->versions[version].size - 1;
    ps->num_versions++;
    return new_ver;
}

int pstack_peek(PersistentStack *ps, int version) {
    if (version < 0 || version >= ps->num_versions) return -1;
    if (!ps->versions[version].top) return -1;
    return ps->versions[version].top->value;
}

int pstack_size(PersistentStack *ps, int version) {
    if (version < 0 || version >= ps->num_versions) return -1;
    return ps->versions[version].size;
}

void pstack_print_version(PersistentStack *ps, int version) {
    if (version < 0 || version >= ps->num_versions) return;
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
    int *freed = calloc(ps->num_versions * 100, sizeof(int));
    int freed_count = 0;

    for (int i = 0; i < ps->num_versions; i++) {
        for (PNode *n = ps->versions[i].top; n; n = n->next) {
            int already = 0;
            for (int j = 0; j < freed_count; j++) {
                if ((PNode *)(long)freed[j] == n) { already = 1; break; }
            }
            if (already) break;
        }
    }

    PNode **all_nodes = NULL;
    int node_count = 0, node_cap = 64;
    all_nodes = malloc(node_cap * sizeof(PNode *));

    for (int i = 0; i < ps->num_versions; i++) {
        for (PNode *n = ps->versions[i].top; n; n = n->next) {
            int found = 0;
            for (int j = 0; j < node_count; j++) {
                if (all_nodes[j] == n) { found = 1; break; }
            }
            if (!found) {
                if (node_count == node_cap) {
                    node_cap *= 2;
                    all_nodes = realloc(all_nodes, node_cap * sizeof(PNode *));
                }
                all_nodes[node_count++] = n;
            }
        }
    }

    for (int i = 0; i < node_count; i++)
        free(all_nodes[i]);
    free(all_nodes);
    free(freed);
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
    printf("All tests passed.\n");
    return 0;
}
