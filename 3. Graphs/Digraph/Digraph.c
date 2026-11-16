#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <limits.h>

typedef struct {
    int src, dst, weight;
} Edge;

typedef struct {
    int V, E, cap;
    Edge *edges;
} Digraph;

static int valid_vertex(const Digraph *g, int v) {
    return g && v >= 0 && v < g->V;
}

Digraph *digraph_create(int V, int cap) {
    if (V < 0 || cap < 0) return NULL;
    Digraph *g = malloc(sizeof(*g));
    if (!g) return NULL;
    g->V = V;
    g->E = 0;
    g->cap = cap;
    g->edges = calloc(cap, sizeof(Edge));
    if (!g->edges && cap) {
        free(g);
        return NULL;
    }
    return g;
}

void digraph_add_edge(Digraph *g, int src, int dst, int weight) {
    if (!valid_vertex(g, src) || !valid_vertex(g, dst)) return;
    if (g->E == g->cap) {
        if (g->cap > INT_MAX / 2) return;
        int cap = g->cap ? g->cap * 2 : 1;
        if ((size_t)cap > SIZE_MAX / sizeof(Edge)) return;
        Edge *edges = realloc(g->edges, (size_t)cap * sizeof(*edges));
        if (!edges) return;
        g->edges = edges;
        g->cap = cap;
    }
    g->edges[g->E].src = src;
    g->edges[g->E].dst = dst;
    g->edges[g->E].weight = weight;
    g->E++;
}

int digraph_has_edge(Digraph *g, int src, int dst) {
    if (!valid_vertex(g, src) || !valid_vertex(g, dst)) return 0;
    for (int i = 0; i < g->E; i++)
        if (g->edges[i].src == src && g->edges[i].dst == dst)
            return 1;
    return 0;
}

void digraph_remove_edge(Digraph *g, int src, int dst) {
    if (!valid_vertex(g, src) || !valid_vertex(g, dst)) return;
    for (int i = 0; i < g->E; i++) {
        if (g->edges[i].src == src && g->edges[i].dst == dst) {
            g->edges[i] = g->edges[--g->E];
            return;
        }
    }
}

int digraph_out_degree(Digraph *g, int v) {
    if (!valid_vertex(g, v)) return 0;
    int count = 0;
    for (int i = 0; i < g->E; i++)
        if (g->edges[i].src == v) count++;
    return count;
}

int digraph_in_degree(Digraph *g, int v) {
    if (!valid_vertex(g, v)) return 0;
    int count = 0;
    for (int i = 0; i < g->E; i++)
        if (g->edges[i].dst == v) count++;
    return count;
}

static void dfs_util(Digraph *g, int v, int *visited) {
    visited[v] = 1;
    printf("%d ", v);
    for (int i = 0; i < g->E; i++)
        if (g->edges[i].src == v && !visited[g->edges[i].dst])
            dfs_util(g, g->edges[i].dst, visited);
}

void digraph_dfs(Digraph *g, int start) {
    if (!valid_vertex(g, start)) return;
    int *visited = calloc(g->V, sizeof(int));
    if (visited) dfs_util(g, start, visited);
    free(visited);
}

static int topo_util(Digraph *g, int v, int *state, int *stack, int *top) {
    state[v] = 1;
    for (int i = 0; i < g->E; i++) {
        if (g->edges[i].src != v) continue;
        int dst = g->edges[i].dst;
        if (state[dst] == 1) return 0;
        if (!state[dst] && !topo_util(g, dst, state, stack, top)) return 0;
    }
    state[v] = 2;
    stack[(*top)++] = v;
    return 1;
}

void digraph_topological_sort(Digraph *g) {
    if (!g || !g->V) return;
    int *state = calloc(g->V, sizeof(*state));
    int *stack = calloc(g->V, sizeof(*stack));
    int top = 0;
    if (state && stack) {
        for (int i = 0; i < g->V; i++) {
            if (!state[i] && !topo_util(g, i, state, stack, &top)) {
                printf("Graph contains a cycle");
                top = 0;
                break;
            }
        }
        while (top) printf("%d ", stack[--top]);
    }
    free(state);
    free(stack);
}

void digraph_print(Digraph *g) {
    if (!g) return;
    printf("Digraph: %d vertices, %d edges\n", g->V, g->E);
    for (int i = 0; i < g->E; i++)
        printf("  %d -> %d (w=%d)\n",
               g->edges[i].src, g->edges[i].dst, g->edges[i].weight);
}

void digraph_free(Digraph *g) {
    if (!g) return;
    free(g->edges);
    free(g);
}

int main(void) {
    Digraph *g = digraph_create(6, 4);
    if (!g) return EXIT_FAILURE;

    digraph_add_edge(g, 5, 2, 1);
    digraph_add_edge(g, 5, 0, 1);
    digraph_add_edge(g, 4, 0, 1);
    digraph_add_edge(g, 4, 1, 1);
    digraph_add_edge(g, 2, 3, 1);
    digraph_add_edge(g, 3, 1, 1);

    digraph_print(g);

    printf("Edge 5->2 exists: %d\n", digraph_has_edge(g, 5, 2));
    printf("Edge 2->5 exists: %d\n", digraph_has_edge(g, 2, 5));
    printf("Out-degree of 5: %d\n", digraph_out_degree(g, 5));
    printf("In-degree of 1: %d\n", digraph_in_degree(g, 1));

    printf("DFS from 5: ");
    digraph_dfs(g, 5);
    printf("\n");

    printf("Topological Sort: ");
    digraph_topological_sort(g);
    printf("\n");

    digraph_remove_edge(g, 5, 2);
    printf("After removing 5->2, edge exists: %d\n", digraph_has_edge(g, 5, 2));
    printf("Edge count: %d\n", g->E);

    digraph_free(g);
    return 0;
}
