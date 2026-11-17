# Doubly connected edge list (DCEL)

Each edge of a planar subdivision has two directed half-edges. Each half-edge starts at its origin vertex and ends at its twin’s origin. Following successive half-edges with the same face on their left traces that face’s boundary.

## C representation

The C example divides a square along a diagonal. It links three cycles, one for each triangle and one clockwise cycle around the exterior. Each face stores a starting half-edge. Each vertex stores one outgoing half-edge.

Vertices, half-edges and faces live in separate growable arrays. Links use integer indices, so growing an array preserves existing links. A missing link has index `-1`. On x86-64, a vertex takes 24 bytes, a half-edge 24 bytes and a face 8 bytes. The 48-byte header holds the three arrays, counts and capacities.

Adding a vertex, a face or a twin pair takes amortized O(1) time. Linking two half-edges takes O(1) and requires matching endpoints and faces. Counting a closed face boundary takes O(k) for k half-edges. The count is zero for a missing or incomplete boundary. Storage is O(V + E + F).

## Assembly representation

The assembly example allocates fixed-capacity arrays and uses pointers for links. Vertices, half-edges and faces occupy 32, 48 and 16 bytes respectively on x86-64. The demo creates vertex and face records and joins vertices with twin pairs. The face cycles are illustrated in the C version.
