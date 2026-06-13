# Adjacency Matrix

A 2D matrix representation of a graph where entry `matrix[i][j]` stores the edge weight from vertex `i` to vertex `j`. Zero indicates no edge.

## Memory Mechanics

```
AdjMatrix struct (16 bytes):
┌──────────┬──────────┬──────────────────┐
│  V (4B)  │ pad (4B) │  matrix_ptr (8B) │
└──────────┴──────────┴────────┬─────────┘
                               │
                               ▼
Flat array (V × V × 4 bytes, row-major):
┌────────────────────────────────────────────┐
│ Row 0:  [0,0] [0,1] [0,2] ... [0,V-1]     │
│ Row 1:  [1,0] [1,1] [1,2] ... [1,V-1]     │
│ ...                                        │
│ Row V-1: [V-1,0] ...         [V-1,V-1]    │
└────────────────────────────────────────────┘
```

- **Element access:** `matrix_ptr + (src * V + dst) * 4` — single multiply-add gives the byte offset. O(1) direct indexing.
- **Row-major layout:** All outgoing edges from vertex `i` are contiguous in `matrix[i*V .. i*V + V-1]`, enabling cache-friendly neighbor iteration.
- **Fixed allocation:** The matrix is allocated once via `calloc(V*V, 4)`. No dynamic resizing; vertex count is fixed at creation.
- **Space trade-off:** Dense representation — always `V²` integers regardless of edge count. Wastes memory on sparse graphs.

## Uses

- **Dense graph algorithms:** Floyd-Warshall all-pairs shortest paths operates directly on the matrix with optimal cache behavior.
- **Network connectivity:** Quick O(1) edge existence checks in small, dense networks (routers, circuit boards).
- **Transitive closure:** Matrix multiplication-based reachability computation (Warshall's algorithm).

## Complexities

| Operation     | Time   | Notes                    |
|:--------------|:-------|:-------------------------|
| Add Edge      | O(1)   | Direct array write       |
| Remove Edge   | O(1)   | Set entry to zero        |
| Has Edge      | O(1)   | Direct array read        |
| Get Neighbors | O(V)   | Scan entire row          |
| BFS / DFS     | O(V²)  | Must scan all rows       |
| **Space**     | **O(V²)** | 4V² bytes for int matrix |
