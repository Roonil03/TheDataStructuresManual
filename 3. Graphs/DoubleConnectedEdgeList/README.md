# Double Connected Edge List (DCEL)

A half-edge data structure for representing planar subdivisions. Each undirected edge is stored as a pair of directed half-edges (twins), enabling O(1) traversal of faces, vertices, and edge boundaries.

## Memory Mechanics

```
DCEL struct (40 bytes):
┌──────────────┬──────────────┬──────────────┐
│ verts_ptr(8) │ hedges_ptr(8)│ faces_ptr(8) │
├──────────────┼──────────────┼──────────────┤
│   nv (4)     │   nhe (4)    │   nf (4)     │
└──────────────┴──────────────┴──────────────┘

Vertex (32 bytes):              HalfEdge (48 bytes):
┌──────────┬──────────┐        ┌──────────────┬──────────────┐
│  x (8B)  │  y (8B)  │        │ origin* (8B) │  twin*  (8B) │
├──────────┼──────────┤        ├──────────────┼──────────────┤
│ inc* (8) │  id (4)  │        │  next*  (8B) │  prev*  (8B) │
└──────────┴──────────┘        ├──────────────┼──────────────┤
                               │  face*  (8B) │   id    (4B) │
Face (16 bytes):               └──────────────┴──────────────┘
┌──────────┬──────────┐
│ edge*(8) │  id (4)  │
└──────────┴──────────┘
```

- **Twin pairing:** Every edge becomes two half-edges allocated consecutively. `HE[2k]` and `HE[2k+1]` are always twins. This eliminates twin-lookup overhead.
- **Contiguous arrays:** Vertices, half-edges, and faces each live in their own `realloc`-growable arrays. Pointers between components are raw `Vertex*`, `HalfEdge*`, `Face*` into these arrays.
- **Face traversal:** Following `next` pointers from any half-edge on a face boundary returns to the start, forming a cycle. Edge count per face = cycle length.
- **Pointer invalidation:** `realloc` on any array invalidates all cross-pointers. In production, index-based references are safer.

## Uses

- **Computational geometry:** Voronoi diagrams and Delaunay triangulations store planar subdivisions as DCELs for efficient face/edge enumeration.
- **Mesh processing:** 3D modeling software (Blender, CGAL) uses half-edge structures for mesh traversal, subdivision, and Boolean operations.
- **Map overlay:** GIS systems overlay polygon layers by merging their DCEL representations.

## Complexities

| Operation           | Time   | Notes                          |
|:--------------------|:-------|:-------------------------------|
| Add Vertex          | O(1)*  | Amortized (array append)       |
| Add Edge (pair)     | O(1)*  | Allocate two consecutive HEs   |
| Face Traversal      | O(k)   | k = edges bounding the face    |
| Vertex Neighbors    | O(k)   | k = degree, via twin→next cycle|
| **Space**           | **O(V + E + F)** | 32V + 48·2E + 16F bytes |
