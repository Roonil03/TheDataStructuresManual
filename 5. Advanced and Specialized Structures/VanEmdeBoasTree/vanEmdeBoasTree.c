#include <stdio.h>
#include <stdlib.h>
#include <math.h>

typedef struct vEB {
    int u, min, max;
    struct vEB *summary;
    struct vEB **cluster;
} vEB;

vEB* vEB_create(int u) {
    vEB *V = malloc(sizeof *V);
    V->u = u; V->min = V->max = -1;
    if (u <= 2) { V->summary = NULL; V->cluster = NULL; }
    else {
        int m = ceil(sqrt(u));
        V->summary = vEB_create(m);
        V->cluster = calloc(m, sizeof(vEB*));
        for (int i=0; i<m; i++) V->cluster[i] = vEB_create(floor(sqrt(u)));
    }
    return V;
}

int high(int x, int u) { return x / ceil(sqrt(u)); }
int low(int x, int u)  { return x % (int)ceil(sqrt(u)); }
int idx(int h, int l, int u){ return h*ceil(sqrt(u)) + l; }

void vEB_insert(vEB *V, int x) {
    if (V->min == -1) { V->min = V->max = x; return; }
    if (x < V->min) { int t = V->min; V->min = x; x = t; }
    if (V->u > 2) {
        int h = high(x, V->u), l = low(x, V->u);
        if (V->cluster[h]->min == -1) {
            vEB_insert(V->summary, h);
            V->cluster[h]->min = V->cluster[h]->max = l;
        } else vEB_insert(V->cluster[h], l);
    }
    if (x > V->max) V->max = x;
}

void vEB_delete(vEB *V, int x) {
    if (V->min == V->max) { V->min = V->max = -1; return; }
    if (V->u == 2) {
        if (x == 0) V->min = 1; else V->max = 0;
        return;
    }
    if (x == V->min) {
        int first = V->summary->min;
        x = idx(first, V->cluster[first]->min, V->u);
        V->min = x;
    }
    int h = high(x, V->u), l = low(x, V->u);
    vEB_delete(V->cluster[h], l);
    if (V->cluster[h]->min == -1)
        vEB_delete(V->summary, h);
    if (x == V->max) {
        int smax = V->summary->max;
        if (smax == -1) V->max = V->min;
        else V->max = idx(smax, V->cluster[smax]->max, V->u);
    }
}

int vEB_member(vEB *V, int x) {
    if (x == V->min || x == V->max) return 1;
    if (V->u == 2) return 0;
    return vEB_member(V->cluster[high(x, V->u)], low(x, V->u));
}

int vEB_successor(vEB *V, int x) {
    if (V->u == 2) {
        if (x == 0 && V->max == 1) return 1;
        return -1;
    }
    if (V->min != -1 && x < V->min) return V->min;
    int h = high(x, V->u), l = low(x, V->u);
    int maxLow = V->cluster[h]->max;
    if (maxLow != -1 && l < maxLow)
        return idx(h, vEB_successor(V->cluster[h], l), V->u);
    int succCluster = vEB_successor(V->summary, h);
    if (succCluster == -1) return -1;
    return idx(succCluster, V->cluster[succCluster]->min, V->u);
}

int vEB_predecessor(vEB *V, int x) {
    if (V->u == 2) {
        if (x == 1 && V->min == 0) return 0;
        return -1;
    }
    if (V->max != -1 && x > V->max) return V->max;
    int h = high(x, V->u), l = low(x, V->u);
    int minLow = V->cluster[h]->min;
    if (minLow != -1 && l > minLow)
        return idx(h, vEB_predecessor(V->cluster[h], l), V->u);
    int predCluster = vEB_predecessor(V->summary, h);
    if (predCluster == -1) {
        if (V->min != -1 && x > V->min) return V->min;
        return -1;
    }
    return idx(predCluster, V->cluster[predCluster]->max, V->u);
}

int main() {
    vEB *T = vEB_create(16);
    char op; int x;
    while (scanf(" %c", &op)==1) {
        switch (op) {
            case 'i': scanf("%d",&x); vEB_insert(T,x); printf("Inserted %d\n",x); break;
            case 'd': scanf("%d",&x); vEB_delete(T,x); printf("Deleted %d\n",x); break;
            case 'm': scanf("%d",&x); 
                      printf("%s\n", vEB_member(T,x)?"Found":"Not found");
                      break;
            case 's': scanf("%d",&x); printf("Successor of %d: %d\n",x,vEB_successor(T,x)); break;
            case 'p': printf("Min: %d  Max: %d\n",T->min,T->max); break;
            case 'q': return 0;
        }
    }
    return 0;
}
