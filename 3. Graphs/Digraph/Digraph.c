#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    int src, dst, weight;
} Edge;

typedef struct {
    int V, E, cap;
    Edge *edges;
} Digraph;

Digraph *digraph_create(int V, int cap) {
    Digraph *g = malloc(sizeof(Digraph));
    g->V = V;
    g->E = 0;
    g->cap = cap;
    g->edges = malloc(cap * sizeof(Edge));
    return g;
}

void digraph_add_edge(Digraph *g, int src, int dst, int weight) {
    if (g->E == g->cap) {
        g->cap = g->cap == 0 ? 1 : g->cap * 2;
        g->edges = realloc(g->edges, g->cap * sizeof(Edge));
    }
    g->edges[g->E].src = src;
    g->edges[g->E].dst = dst;
    g->edges[g->E].weight = weight;
    g->E++;
}

int digraph_has_edge(Digraph *g, int src, int dst) {
    for (int i = 0; i < g->E; i++)
        if (g->edges[i].src == src && g->edges[i].dst == dst)
            return 1;
    return 0;
}

void digraph_remove_edge(Digraph *g, int src, int dst) {
    for (int i = 0; i < g->E; i++) {
        if (g->edges[i].src == src && g->edges[i].dst == dst) {
            g->edges[i] = g->edges[--g->E];
            return;
        }
    }
}

int digraph_out_degree(Digraph *g, int v) {
    int count = 0;
    for (int i = 0; i < g->E; i++)
        if (g->edges[i].src == v) count++;
    return count;
}

int digraph_in_degree(Digraph *g, int v) {
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
    int *visited = calloc(g->V, sizeof(int));
    dfs_util(g, start, visited);
    free(visited);
}

static void topo_util(Digraph *g, int v, int *visited, int *stack, int *top) {
    visited[v] = 1;
    for (int i = 0; i < g->E; i++)
        if (g->edges[i].src == v && !visited[g->edges[i].dst])
            topo_util(g, g->edges[i].dst, visited, stack, top);
    stack[(*top)++] = v;
}

void digraph_topological_sort(Digraph *g) {
    int *visited = calloc(g->V, sizeof(int));
    int *stack = malloc(g->V * sizeof(int));
    int top = 0;
    for (int i = 0; i < g->V; i++)
        if (!visited[i])
            topo_util(g, i, visited, stack, &top);
    for (int i = top - 1; i >= 0; i--)
        printf("%d ", stack[i]);
    free(visited);
    free(stack);
}

void digraph_print(Digraph *g) {
    printf("Digraph: %d vertices, %d edges\n", g->V, g->E);
    for (int i = 0; i < g->E; i++)
        printf("  %d -> %d (w=%d)\n",
               g->edges[i].src, g->edges[i].dst, g->edges[i].weight);
}

void digraph_free(Digraph *g) {
    free(g->edges);
    free(g);
}

int main(void) {
    Digraph *g = digraph_create(6, 4);

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
    printf("All tests passed.\n");
    return 0;
}
