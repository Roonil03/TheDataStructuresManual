#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

typedef struct {
    int V;
    int *matrix;
} AdjMatrix;

static int valid_vertex(const AdjMatrix *g, int v) {
    return g && v >= 0 && v < g->V;
}

AdjMatrix *adjmatrix_create(int V) {
    if (V < 0) return NULL;
    if (V && (size_t)V > SIZE_MAX / sizeof(int) / (size_t)V) return NULL;
    AdjMatrix *g = malloc(sizeof(*g));
    if (!g) return NULL;
    g->V = V;
    g->matrix = calloc((size_t)V * V, sizeof(int));
    if (!g->matrix && V) {
        free(g);
        return NULL;
    }
    return g;
}

void adjmatrix_add_edge(AdjMatrix *g, int src, int dst, int weight) {
    if (!valid_vertex(g, src) || !valid_vertex(g, dst)) return;
    g->matrix[(size_t)src * g->V + dst] = weight;
}

void adjmatrix_remove_edge(AdjMatrix *g, int src, int dst) {
    if (!valid_vertex(g, src) || !valid_vertex(g, dst)) return;
    g->matrix[(size_t)src * g->V + dst] = 0;
}

int adjmatrix_has_edge(AdjMatrix *g, int src, int dst) {
    if (!valid_vertex(g, src) || !valid_vertex(g, dst)) return 0;
    return g->matrix[(size_t)src * g->V + dst] != 0;
}

int adjmatrix_get_weight(AdjMatrix *g, int src, int dst) {
    if (!valid_vertex(g, src) || !valid_vertex(g, dst)) return 0;
    return g->matrix[(size_t)src * g->V + dst];
}

void adjmatrix_bfs(AdjMatrix *g, int start) {
    if (!valid_vertex(g, start)) return;
    int *visited = calloc(g->V, sizeof(int));
    int *queue = calloc(g->V, sizeof(int));
    if (!visited || !queue) {
        free(visited);
        free(queue);
        return;
    }
    int front = 0, rear = 0;
    visited[start] = 1;
    queue[rear++] = start;
    while (front < rear) {
        int v = queue[front++];
        printf("%d ", v);
        for (int i = 0; i < g->V; i++) {
            if (g->matrix[(size_t)v * g->V + i] && !visited[i]) {
                visited[i] = 1;
                queue[rear++] = i;
            }
        }
    }
    free(visited);
    free(queue);
}

void adjmatrix_print(AdjMatrix *g) {
    if (!g) return;
    printf("Adjacency Matrix (%d vertices):\n", g->V);
    for (int i = 0; i < g->V; i++) {
        for (int j = 0; j < g->V; j++)
            printf("%3d ", g->matrix[(size_t)i * g->V + j]);
        printf("\n");
    }
}

void adjmatrix_free(AdjMatrix *g) {
    if (!g) return;
    free(g->matrix);
    free(g);
}

int main(void) {
    AdjMatrix *g = adjmatrix_create(5);
    if (!g) return EXIT_FAILURE;
    adjmatrix_add_edge(g, 0, 1, 10);
    adjmatrix_add_edge(g, 0, 4, 20);
    adjmatrix_add_edge(g, 1, 2, 30);
    adjmatrix_add_edge(g, 1, 3, 40);
    adjmatrix_add_edge(g, 1, 4, 50);
    adjmatrix_add_edge(g, 2, 3, 60);
    adjmatrix_add_edge(g, 3, 4, 70);

    adjmatrix_print(g);
    printf("Edge 0->1 exists: %d\n", adjmatrix_has_edge(g, 0, 1));
    printf("Edge 1->0 exists: %d\n", adjmatrix_has_edge(g, 1, 0));
    printf("Weight 1->2: %d\n", adjmatrix_get_weight(g, 1, 2));

    printf("BFS from 0: ");
    adjmatrix_bfs(g, 0);
    printf("\n");

    adjmatrix_remove_edge(g, 0, 1);
    printf("After removing 0->1, exists: %d\n", adjmatrix_has_edge(g, 0, 1));

    adjmatrix_free(g);
    return 0;
}
