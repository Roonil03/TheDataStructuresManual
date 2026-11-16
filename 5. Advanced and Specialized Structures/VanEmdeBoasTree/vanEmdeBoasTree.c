#include <stdio.h>
#include <stdlib.h>

/* The minimum is stored separately; the summary indexes nonempty clusters. */
typedef struct vEB {
    int u, min, max, lower, upper;
    struct vEB *summary;
    struct vEB **cluster;
} vEB;

static void *checked_alloc(size_t size) {
    void *p = malloc(size);
    if (!p) {
        fputs("Allocation failed\n", stderr);
        exit(EXIT_FAILURE);
    }
    return p;
}

static int lower_size(int u) {
    int bits = 0;
    for (int n = u; n > 1; n /= 2) bits++;
    return 1 << (bits / 2);
}

int high(int x, int u) { return x / lower_size(u); }
int low(int x, int u) { return x % lower_size(u); }
int idx(int h, int l, int u) { return h * lower_size(u) + l; }

vEB *vEB_create(int u) {
    if (u < 2 || (u & (u - 1))) return NULL;
    vEB *V = checked_alloc(sizeof *V);
    V->u = u;
    V->min = V->max = -1;
    V->lower = lower_size(u);
    V->upper = u / V->lower;
    V->summary = NULL;
    V->cluster = NULL;
    if (u > 2) {
        int lower = V->lower, upper = V->upper;
        V->summary = vEB_create(upper);
        V->cluster = checked_alloc((size_t)upper * sizeof *V->cluster);
        for (int i = 0; i < upper; i++) V->cluster[i] = vEB_create(lower);
    }
    return V;
}

int vEB_member(vEB *V, int x) {
    if (!V || x < 0 || x >= V->u || V->min == -1) return 0;
    if (x == V->min || x == V->max) return 1;
    if (V->u == 2) return 0;
    return vEB_member(V->cluster[x / V->lower], x % V->lower);
}

static void insert_absent(vEB *V, int x) {
    if (V->min == -1) { V->min = V->max = x; return; }
    if (x < V->min) { int t = V->min; V->min = x; x = t; }
    if (V->u > 2) {
        int h = x / V->lower, l = x % V->lower;
        if (V->cluster[h]->min == -1) {
            insert_absent(V->summary, h);
            V->cluster[h]->min = V->cluster[h]->max = l;
        } else insert_absent(V->cluster[h], l);
    }
    if (x > V->max) V->max = x;
}

void vEB_insert(vEB *V, int x) {
    if (V && x >= 0 && x < V->u && !vEB_member(V, x)) insert_absent(V, x);
}

static void delete_present(vEB *V, int x) {
    if (V->min == V->max) { V->min = V->max = -1; return; }
    if (V->u == 2) {
        if (x == 0) V->min = 1; else V->max = 0;
        return;
    }
    if (x == V->min) {
        int first = V->summary->min;
        x = first * V->lower + V->cluster[first]->min;
        V->min = x;
    }
    int h = x / V->lower, l = x % V->lower;
    delete_present(V->cluster[h], l);
    if (V->cluster[h]->min == -1) delete_present(V->summary, h);
    if (x == V->max) {
        int smax = V->summary->max;
        if (smax == -1) V->max = V->min;
        else V->max = smax * V->lower + V->cluster[smax]->max;
    }
}

void vEB_delete(vEB *V, int x) {
    if (vEB_member(V, x)) delete_present(V, x);
}

int vEB_successor(vEB *V, int x) {
    if (!V || V->min == -1 || x >= V->max) return -1;
    if (x < V->min) return V->min;
    if (V->u == 2) return 1;
    int h = x / V->lower, l = x % V->lower;
    int max_low = V->cluster[h]->max;
    if (max_low != -1 && l < max_low)
        return h * V->lower + vEB_successor(V->cluster[h], l);
    int succ_cluster = vEB_successor(V->summary, h);
    if (succ_cluster == -1) return -1;
    return succ_cluster * V->lower + V->cluster[succ_cluster]->min;
}

int vEB_predecessor(vEB *V, int x) {
    if (!V || V->min == -1 || x <= V->min) return -1;
    if (x > V->max) return V->max;
    if (V->u == 2) return 0;
    int h = x / V->lower, l = x % V->lower;
    int min_low = V->cluster[h]->min;
    if (min_low != -1 && l > min_low)
        return h * V->lower + vEB_predecessor(V->cluster[h], l);
    int pred_cluster = vEB_predecessor(V->summary, h);
    if (pred_cluster == -1) return V->min;
    return pred_cluster * V->lower + V->cluster[pred_cluster]->max;
}

void vEB_free(vEB *V) {
    if (!V) return;
    if (V->u > 2) {
        for (int i = 0; i < V->upper; i++) vEB_free(V->cluster[i]);
        free(V->cluster);
        vEB_free(V->summary);
    }
    free(V);
}

int main(void) {
    vEB *T = vEB_create(16);
    char op;
    int x;
    while (scanf(" %c", &op) == 1) {
        if (op == 'q') break;
        if (op == 'p') {
            printf("Min: %d  Max: %d\n", T->min, T->max);
            continue;
        }
        if (op != 'i' && op != 'd' && op != 'm' && op != 's' && op != 'r') continue;
        if (scanf("%d", &x) != 1) break;
        switch (op) {
            case 'i':
                if (x < 0 || x >= T->u) printf("Out of range\n");
                else { vEB_insert(T, x); printf("Inserted %d\n", x); }
                break;
            case 'd': vEB_delete(T, x); printf("Deleted %d\n", x); break;
            case 'm': printf("%s\n", vEB_member(T, x) ? "Found" : "Not found"); break;
            case 's': printf("Successor of %d: %d\n", x, vEB_successor(T, x)); break;
            case 'r': printf("Predecessor of %d: %d\n", x, vEB_predecessor(T, x)); break;
        }
    }
    vEB_free(T);
    return 0;
}
