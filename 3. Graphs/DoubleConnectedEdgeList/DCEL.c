#include <stdio.h>
#include <stdlib.h>

#include <limits.h>
#include <stdint.h>

/* Array indices keep the links valid when a vertex, face or half-edge array grows. */
typedef struct {
    double x, y;
    int incident, id;
} Vertex;

typedef struct {
    int edge, id;
} Face;

typedef struct {
    int origin, twin, next, prev, face, id;
} HalfEdge;

typedef struct {
    Vertex *vertices;
    HalfEdge *half_edges;
    Face *faces;
    int nv, nhe, nf;
    int cap_v, cap_he, cap_f;
} DCEL;

DCEL *dcel_create(int cap_v, int cap_he, int cap_f) {
    if (cap_v < 0 || cap_he < 0 || cap_f < 0) return NULL;
    DCEL *d = calloc(1, sizeof(*d));
    if (!d) return NULL;
    d->vertices = calloc(cap_v, sizeof(Vertex));
    d->half_edges = calloc(cap_he, sizeof(HalfEdge));
    d->faces = calloc(cap_f, sizeof(Face));
    if ((cap_v && !d->vertices) || (cap_he && !d->half_edges) || (cap_f && !d->faces)) {
        free(d->vertices);
        free(d->half_edges);
        free(d->faces);
        free(d);
        return NULL;
    }
    d->cap_v = cap_v;
    d->cap_he = cap_he;
    d->cap_f = cap_f;
    return d;
}

static void *grow(void *array, int *capacity, int minimum, size_t element_size) {
    int count = *capacity <= INT_MAX / 2 ? *capacity * 2 : INT_MAX;
    if (count < minimum) count = minimum;
    if ((size_t)count > SIZE_MAX / element_size) return NULL;
    void *result = realloc(array, (size_t)count * element_size);
    if (result) *capacity = count;
    return result;
}

int dcel_add_vertex(DCEL *d, double x, double y) {
    if (!d || d->nv == INT_MAX) return -1;
    if (d->nv == d->cap_v) {
        Vertex *vertices = grow(d->vertices, &d->cap_v, d->nv + 1, sizeof(Vertex));
        if (!vertices) return -1;
        d->vertices = vertices;
    }
    int id = d->nv++;
    d->vertices[id] = (Vertex){x, y, -1, id};
    return id;
}

int dcel_add_face(DCEL *d) {
    if (!d || d->nf == INT_MAX) return -1;
    if (d->nf == d->cap_f) {
        Face *faces = grow(d->faces, &d->cap_f, d->nf + 1, sizeof(Face));
        if (!faces) return -1;
        d->faces = faces;
    }
    int id = d->nf++;
    d->faces[id] = (Face){-1, id};
    return id;
}

void dcel_add_edge(DCEL *d, int v1, int v2, int face_left, int face_right) {
    if (!d || v1 < 0 || v1 >= d->nv || v2 < 0 || v2 >= d->nv ||
        face_left < -1 || face_left >= d->nf || face_right < -1 || face_right >= d->nf ||
        d->nhe > INT_MAX - 2) return;
    if (d->cap_he - d->nhe < 2) {
        HalfEdge *edges = grow(d->half_edges, &d->cap_he, d->nhe + 2, sizeof(HalfEdge));
        if (!edges) return;
        d->half_edges = edges;
    }
    int first = d->nhe, second = first + 1;
    d->half_edges[first] = (HalfEdge){v1, second, -1, -1, face_left, first};
    d->half_edges[second] = (HalfEdge){v2, first, -1, -1, face_right, second};
    d->nhe += 2;
    if (face_left >= 0 && d->faces[face_left].edge < 0) d->faces[face_left].edge = first;
    if (face_right >= 0 && d->faces[face_right].edge < 0) d->faces[face_right].edge = second;
    if (d->vertices[v1].incident < 0) d->vertices[v1].incident = first;
    if (d->vertices[v2].incident < 0) d->vertices[v2].incident = second;
}

void dcel_set_next_prev(DCEL *d, int he_id, int next_id) {
    if (!d || he_id < 0 || he_id >= d->nhe || next_id < 0 || next_id >= d->nhe) return;
    HalfEdge *he = &d->half_edges[he_id], *next = &d->half_edges[next_id];
    if (he->face != next->face || d->half_edges[he->twin].origin != next->origin) return;
    if (he->next >= 0) d->half_edges[he->next].prev = -1;
    if (next->prev >= 0) d->half_edges[next->prev].next = -1;
    he->next = next_id;
    next->prev = he_id;
}

void dcel_print_vertices(DCEL *d) {
    printf("Vertices (%d):\n", d->nv);
    for (int i = 0; i < d->nv; i++)
        printf("  V%d: (%.1f, %.1f) incident_he=%d\n", i,
               d->vertices[i].x, d->vertices[i].y,
               d->vertices[i].incident);
}

void dcel_print_half_edges(DCEL *d) {
    printf("Half-Edges (%d):\n", d->nhe);
    for (int i = 0; i < d->nhe; i++) {
        HalfEdge *he = &d->half_edges[i];
        printf("  HE%d: origin=V%d twin=HE%d", i,
               he->origin,
               he->twin);
        printf(" next=HE%d prev=HE%d face=F%d\n",
               he->next,
               he->prev,
               he->face);
    }
}

void dcel_print_faces(DCEL *d) {
    printf("Faces (%d):\n", d->nf);
    for (int i = 0; i < d->nf; i++)
        printf("  F%d: edge=HE%d\n", i,
               d->faces[i].edge);
}

int dcel_face_edge_count(DCEL *d, int face_id) {
    if (!d || face_id < 0 || face_id >= d->nf) return 0;
    int start = d->faces[face_id].edge;
    int current = start, count = 0;
    do {
        if (current < 0 || count == d->nhe) return 0;
        count++;
        current = d->half_edges[current].next;
    } while (current != start);
    return count;
}

void dcel_free(DCEL *d) {
    if (!d) return;
    free(d->vertices);
    free(d->half_edges);
    free(d->faces);
    free(d);
}

int main(void) {
    DCEL *d = dcel_create(8, 16, 4);

    if (!d) return EXIT_FAILURE;
    int v0 = dcel_add_vertex(d, 0.0, 0.0);
    int v1 = dcel_add_vertex(d, 1.0, 0.0);
    int v2 = dcel_add_vertex(d, 1.0, 1.0);
    int v3 = dcel_add_vertex(d, 0.0, 1.0);

    int f0 = dcel_add_face(d);
    int f1 = dcel_add_face(d);

    int exterior = dcel_add_face(d);

    dcel_add_edge(d, v0, v1, f0, exterior);
    dcel_add_edge(d, v1, v2, f0, exterior);
    dcel_add_edge(d, v2, v3, f1, exterior);
    dcel_add_edge(d, v3, v0, f1, exterior);
    dcel_add_edge(d, v2, v0, f0, f1);

    dcel_set_next_prev(d, 0, 2);
    dcel_set_next_prev(d, 2, 8);
    dcel_set_next_prev(d, 8, 0);
    dcel_set_next_prev(d, 9, 4);
    dcel_set_next_prev(d, 4, 6);
    dcel_set_next_prev(d, 6, 9);
    dcel_set_next_prev(d, 1, 7);
    dcel_set_next_prev(d, 7, 5);
    dcel_set_next_prev(d, 5, 3);
    dcel_set_next_prev(d, 3, 1);

    dcel_print_vertices(d);
    dcel_print_half_edges(d);
    dcel_print_faces(d);

    printf("Face F%d edge count: %d\n", f0, dcel_face_edge_count(d, f0));
    printf("Face F%d edge count: %d\n", f1, dcel_face_edge_count(d, f1));

    printf("Vertex count: %d\n", d->nv);
    printf("Half-edge count: %d\n", d->nhe);
    printf("Face count: %d\n", d->nf);

    dcel_free(d);
    return 0;
}
