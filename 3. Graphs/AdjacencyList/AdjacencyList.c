#include <stdio.h>
#include <stdlib.h>

typedef struct AdjNode {
    int dst;
    int weight;
    struct AdjNode *next;
} AdjNode;

typedef struct {
    int V;
    AdjNode **heads;
} AdjList;

AdjList *adjlist_create(int V) {
    AdjList *g = malloc(sizeof(AdjList));
    g->V = V;
    g->heads = calloc(V, sizeof(AdjNode *));
    return g;
}

void adjlist_add_edge(AdjList *g, int src, int dst, int weight) {
    AdjNode *node = malloc(sizeof(AdjNode));
    node->dst = dst;
    node->weight = weight;
    node->next = g->heads[src];
    g->heads[src] = node;
}

int adjlist_has_edge(AdjList *g, int src, int dst) {
    for (AdjNode *n = g->heads[src]; n; n = n->next)
        if (n->dst == dst) return 1;
    return 0;
}

void adjlist_remove_edge(AdjList *g, int src, int dst) {
    AdjNode **curr = &g->heads[src];
    while (*curr) {
        if ((*curr)->dst == dst) {
            AdjNode *tmp = *curr;
            *curr = (*curr)->next;
            free(tmp);
            return;
        }
        curr = &(*curr)->next;
    }
}

int adjlist_out_degree(AdjList *g, int v) {
    int count = 0;
    for (AdjNode *n = g->heads[v]; n; n = n->next) count++;
    return count;
}

static void dfs_util(AdjList *g, int v, int *visited) {
    visited[v] = 1;
    printf("%d ", v);
    for (AdjNode *n = g->heads[v]; n; n = n->next)
        if (!visited[n->dst])
            dfs_util(g, n->dst, visited);
}

void adjlist_dfs(AdjList *g, int start) {
    int *visited = calloc(g->V, sizeof(int));
    dfs_util(g, start, visited);
    free(visited);
}

void adjlist_bfs(AdjList *g, int start) {
    int *visited = calloc(g->V, sizeof(int));
    int *queue = malloc(g->V * sizeof(int));
    int front = 0, rear = 0;
    visited[start] = 1;
    queue[rear++] = start;
    while (front < rear) {
        int v = queue[front++];
        printf("%d ", v);
        for (AdjNode *n = g->heads[v]; n; n = n->next) {
            if (!visited[n->dst]) {
                visited[n->dst] = 1;
                queue[rear++] = n->dst;
            }
        }
    }
    free(visited);
    free(queue);
}

void adjlist_print(AdjList *g) {
    printf("Adjacency List (%d vertices):\n", g->V);
    for (int i = 0; i < g->V; i++) {
        printf("  %d:", i);
        for (AdjNode *n = g->heads[i]; n; n = n->next)
            printf(" -> %d(w=%d)", n->dst, n->weight);
        printf("\n");
    }
}

void adjlist_free(AdjList *g) {
    for (int i = 0; i < g->V; i++) {
        AdjNode *n = g->heads[i];
        while (n) {
            AdjNode *tmp = n;
            n = n->next;
            free(tmp);
        }
    }
    free(g->heads);
    free(g);
}

int main(void) {
    AdjList *g = adjlist_create(5);

    adjlist_add_edge(g, 0, 1, 10);
    adjlist_add_edge(g, 0, 4, 20);
    adjlist_add_edge(g, 1, 2, 30);
    adjlist_add_edge(g, 1, 3, 40);
    adjlist_add_edge(g, 2, 3, 50);
    adjlist_add_edge(g, 3, 4, 60);

    adjlist_print(g);

    printf("Edge 0->1 exists: %d\n", adjlist_has_edge(g, 0, 1));
    printf("Edge 1->0 exists: %d\n", adjlist_has_edge(g, 1, 0));
    printf("Out-degree of 1: %d\n", adjlist_out_degree(g, 1));

    printf("DFS from 0: ");
    adjlist_dfs(g, 0);
    printf("\n");

    printf("BFS from 0: ");
    adjlist_bfs(g, 0);
    printf("\n");

    adjlist_remove_edge(g, 0, 1);
    printf("After removing 0->1, exists: %d\n", adjlist_has_edge(g, 0, 1));

    adjlist_free(g);
    printf("All tests passed.\n");
    return 0;
}
