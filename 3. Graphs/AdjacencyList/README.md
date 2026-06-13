# Adjacency List

An array of linked lists where each index represents a vertex and the linked list at that index contains all vertices reachable via outgoing edges.

## Memory Mechanics

```
AdjList struct (16 bytes):
┌──────────┬──────────┬──────────────────┐
│  V (4B)  │ pad (4B) │  heads_ptr (8B)  │
└──────────┴──────────┴────────┬─────────┘
                               │
                               ▼
Heads array (V × 8 bytes, array of pointers):
┌──────────┬──────────┬──────────┬─────┐
│ head[0]  │ head[1]  │ head[2]  │ ... │
└────┬─────┴────┬─────┴──────────┴─────┘
     │          │
     ▼          ▼
  AdjNode    AdjNode
  ┌────────┐ ┌────────┐
  │dst  (4)│ │dst  (4)│
  │wt   (4)│ │wt   (4)│
  │next (8)│ │next (8)│──→ AdjNode ──→ NULL
  └───┬────┘ └────────┘
      ▼
   AdjNode ──→ NULL
```

- **Node size:** 16 bytes each (4 + 4 + 8). Individually `malloc`'d; nodes for the same vertex are **not** contiguous.
- **Prepend insertion:** New edges are inserted at the head of the list — O(1) by updating the head pointer. This means iteration order is reverse insertion order.
- **Pointer-chase deletion:** Removal uses a double-pointer (`**curr`) to relink the chain without special-casing the head node.
- **Per-vertex locality:** All neighbors of a vertex are accessed by traversing a linked list — cache-unfriendly for large fan-outs compared to array-backed adjacency.

## Uses

- **Sparse graph storage:** Social network graphs (billions of vertices, sparse connections) use adjacency lists to avoid O(V²) matrix overhead.
- **Graph traversal engines:** BFS/DFS implementations (web crawlers, garbage collectors) iterate per-vertex neighbor lists.
- **Dependency graphs:** Package managers and build systems store per-node dependency chains.

## Complexities

| Operation      | Time         | Notes                         |
|:---------------|:-------------|:------------------------------|
| Add Edge       | O(1)         | Prepend to head               |
| Remove Edge    | O(degree(v)) | Linked-list scan              |
| Has Edge       | O(degree(v)) | Linked-list scan              |
| Get Neighbors  | O(degree(v)) | Direct chain traversal        |
| BFS / DFS      | O(V + E)     | Optimal for sparse graphs     |
| **Space**      | **O(V + E)** | 8V bytes heads + 16E bytes nodes |
