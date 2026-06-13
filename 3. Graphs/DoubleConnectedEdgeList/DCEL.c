#include <stdio.h>
#include <stdlib.h>

typedef struct HalfEdge HalfEdge;
typedef struct Vertex Vertex;
typedef struct Face Face;

struct Vertex {
    double x, y;
    HalfEdge *incident;
    int id;
};

struct Face {
    HalfEdge *edge;
    int id;
};

struct HalfEdge {
    Vertex *origin;
    HalfEdge *twin;
    HalfEdge *next;
    HalfEdge *prev;
    Face *face;
    int id;
};

typedef struct {
    Vertex *vertices;
    HalfEdge *half_edges;
    Face *faces;
    int nv, nhe, nf;
    int cap_v, cap_he, cap_f;
} DCEL;

DCEL *dcel_create(int cap_v, int cap_he, int cap_f) {
    DCEL *d = malloc(sizeof(DCEL));
    d->nv = 0; d->nhe = 0; d->nf = 0;
    d->cap_v = cap_v; d->cap_he = cap_he; d->cap_f = cap_f;
    d->vertices = malloc(cap_v * sizeof(Vertex));
    d->half_edges = malloc(cap_he * sizeof(HalfEdge));
    d->faces = malloc(cap_f * sizeof(Face));
    return d;
}

int dcel_add_vertex(DCEL *d, double x, double y) {
    if (d->nv == d->cap_v) {
        d->cap_v = d->cap_v == 0 ? 1 : d->cap_v * 2;
        d->vertices = realloc(d->vertices, d->cap_v * sizeof(Vertex));
    }
    int id = d->nv;
    d->vertices[id].x = x;
    d->vertices[id].y = y;
    d->vertices[id].incident = NULL;
    d->vertices[id].id = id;
    d->nv++;
    return id;
}

int dcel_add_face(DCEL *d) {
    if (d->nf == d->cap_f) {
        d->cap_f = d->cap_f == 0 ? 1 : d->cap_f * 2;
        d->faces = realloc(d->faces, d->cap_f * sizeof(Face));
    }
    int id = d->nf;
    d->faces[id].edge = NULL;
    d->faces[id].id = id;
    d->nf++;
    return id;
}

static HalfEdge *alloc_half_edge(DCEL *d) {
    if (d->nhe == d->cap_he) {
        d->cap_he = d->cap_he == 0 ? 1 : d->cap_he * 2;
        d->half_edges = realloc(d->half_edges, d->cap_he * sizeof(HalfEdge));
    }
    HalfEdge *he = &d->half_edges[d->nhe];
    he->id = d->nhe;
    he->origin = NULL;
    he->twin = NULL;
    he->next = NULL;
    he->prev = NULL;
    he->face = NULL;
    d->nhe++;
    return he;
}

void dcel_add_edge(DCEL *d, int v1, int v2, int face_left, int face_right) {
    HalfEdge *he1 = alloc_half_edge(d);
    HalfEdge *he2 = alloc_half_edge(d);

    he1->origin = &d->vertices[v1];
    he2->origin = &d->vertices[v2];
    he1->twin = he2;
    he2->twin = he1;

    if (face_left >= 0 && face_left < d->nf) {
        he1->face = &d->faces[face_left];
        if (!d->faces[face_left].edge)
            d->faces[face_left].edge = he1;
    }
    if (face_right >= 0 && face_right < d->nf) {
        he2->face = &d->faces[face_right];
        if (!d->faces[face_right].edge)
            d->faces[face_right].edge = he2;
    }

    if (!d->vertices[v1].incident) d->vertices[v1].incident = he1;
    if (!d->vertices[v2].incident) d->vertices[v2].incident = he2;
}

void dcel_set_next_prev(DCEL *d, int he_id, int next_id) {
    d->half_edges[he_id].next = &d->half_edges[next_id];
    d->half_edges[next_id].prev = &d->half_edges[he_id];
}

void dcel_print_vertices(DCEL *d) {
    printf("Vertices (%d):\n", d->nv);
    for (int i = 0; i < d->nv; i++)
        printf("  V%d: (%.1f, %.1f) incident_he=%d\n", i,
               d->vertices[i].x, d->vertices[i].y,
               d->vertices[i].incident ? d->vertices[i].incident->id : -1);
}

void dcel_print_half_edges(DCEL *d) {
    printf("Half-Edges (%d):\n", d->nhe);
    for (int i = 0; i < d->nhe; i++) {
        HalfEdge *he = &d->half_edges[i];
        printf("  HE%d: origin=V%d twin=HE%d", i,
               he->origin ? he->origin->id : -1,
               he->twin ? he->twin->id : -1);
        printf(" next=HE%d prev=HE%d face=F%d\n",
               he->next ? he->next->id : -1,
               he->prev ? he->prev->id : -1,
               he->face ? he->face->id : -1);
    }
}

void dcel_print_faces(DCEL *d) {
    printf("Faces (%d):\n", d->nf);
    for (int i = 0; i < d->nf; i++)
        printf("  F%d: edge=HE%d\n", i,
               d->faces[i].edge ? d->faces[i].edge->id : -1);
}

int dcel_face_edge_count(DCEL *d, int face_id) {
    HalfEdge *start = d->faces[face_id].edge;
    if (!start) return 0;
    int count = 0;
    HalfEdge *curr = start;
    do {
        count++;
        curr = curr->next;
    } while (curr && curr != start);
    return count;
}

void dcel_free(DCEL *d) {
    free(d->vertices);
    free(d->half_edges);
    free(d->faces);
    free(d);
}

int main(void) {
    DCEL *d = dcel_create(8, 16, 4);

    int v0 = dcel_add_vertex(d, 0.0, 0.0);
    int v1 = dcel_add_vertex(d, 1.0, 0.0);
    int v2 = dcel_add_vertex(d, 1.0, 1.0);
    int v3 = dcel_add_vertex(d, 0.0, 1.0);

    int f0 = dcel_add_face(d);
    int f1 = dcel_add_face(d);

    dcel_add_edge(d, v0, v1, f0, f1);
    dcel_add_edge(d, v1, v2, f0, f1);
    dcel_add_edge(d, v2, v3, f0, f1);
    dcel_add_edge(d, v3, v0, f0, f1);
    dcel_add_edge(d, v0, v2, f0, f1);

    dcel_set_next_prev(d, 0, 2);
    dcel_set_next_prev(d, 2, 8);
    dcel_set_next_prev(d, 8, 0);

    dcel_set_next_prev(d, 9, 4);
    dcel_set_next_prev(d, 4, 6);
    dcel_set_next_prev(d, 6, 9);

    dcel_print_vertices(d);
    dcel_print_half_edges(d);
    dcel_print_faces(d);

    printf("Face F%d edge count: %d\n", f0, dcel_face_edge_count(d, f0));
    printf("Face F%d edge count: %d\n", f1, dcel_face_edge_count(d, f1));

    printf("Vertex count: %d\n", d->nv);
    printf("Half-edge count: %d\n", d->nhe);
    printf("Face count: %d\n", d->nf);

    dcel_free(d);
    printf("All tests passed.\n");
    return 0;
}
