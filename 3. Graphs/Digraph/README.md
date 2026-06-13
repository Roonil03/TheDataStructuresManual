# Digraph (Directed Graph)

A graph where every edge has a direction — an ordered pair *(u, v)* meaning "from *u* to *v*". Unlike undirected graphs, edge *(u, v)* does **not** imply *(v, u)*.

## Memory Mechanics

This implementation uses an **edge list** representation:

```
Digraph struct (24 bytes):
┌──────────┬──────────┬──────────┬──────────┬──────────────────┐
│  V (4B)  │  E (4B)  │ cap (4B) │ pad (4B) │  edges_ptr (8B)  │
└──────────┴──────────┴──────────┴──────────┴────────┬─────────┘
                                                     │
                                                     ▼
Edge array (contiguous, E × 12 bytes):
┌─────────────────┬─────────────────┬─────────────────┬─────┐
│  Edge 0 (12B)   │  Edge 1 (12B)   │  Edge 2 (12B)   │ ... │
│ src | dst | wt  │ src | dst | wt  │ src | dst | wt  │     │
└─────────────────┴─────────────────┴─────────────────┴─────┘
```

- **Edge access:** `edges_ptr + i * 12` gives direct offset to edge *i*.
- **Dynamic growth:** When `E == cap`, the edge array is `realloc`'d to `2 × cap × sizeof(Edge)`. This amortizes insertion cost.
- **Deletion:** Swap-with-last — the removed edge is overwritten by the final edge, then `E` is decremented. O(1) removal, but breaks insertion order.

The edge list stores **no per-vertex structure**. Vertex queries (degree, adjacency) require a linear scan of the entire edge array.

## Uses

- **Dependency resolution:** Task schedulers and build systems (e.g., `make`) model dependencies as directed edges, then topologically sort.
- **Web crawling:** Pages are vertices; hyperlinks are directed edges. Crawlers traverse the digraph via BFS/DFS.
- **Control flow analysis:** Compilers represent basic blocks as vertices and jumps/branches as directed edges for optimization passes.

## Complexities

| Operation    | Time       | Notes                          |
|:-------------|:-----------|:-------------------------------|
| Add Edge     | O(1)*      | Amortized; O(n) on realloc     |
| Remove Edge  | O(E)       | Linear scan + swap-with-last   |
| Has Edge     | O(E)       | Linear scan                    |
| In/Out Degree| O(E)       | Full edge array scan           |
| DFS / BFS    | O(V × E)   | Edge list requires repeated scan per vertex |
| **Space**    | **O(E)**   | 12 bytes per edge + 24 byte header |

*For adjacency-heavy workloads (frequent neighbor queries), an adjacency list or matrix representation is preferred. The edge list excels when the primary operations are iteration over all edges (e.g., Bellman-Ford, Kruskal's).*
