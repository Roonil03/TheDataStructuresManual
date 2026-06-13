# Persistent Data Structures

A data structure where modifications produce new versions without destroying previous ones. This implementation demonstrates **partial persistence** via a persistent stack using structural sharing (node reuse across versions).

## Memory Mechanics

```
PersistentStack struct:
┌──────────────────┬──────────────┬──────────┐
│ versions_ptr (8) │ num_vers (4) │ cap (4)  │
└────────┬─────────┴──────────────┴──────────┘
         │
         ▼
Version array (num_versions × PStack, 16 bytes each):
┌────────────────┬────────────────┬────────────────┐
│ v0: top=NULL   │ v1: top=──┐   │ v2: top=──┐   │...
│     size=0     │     size=1 │   │     size=2 │   │
└────────────────┴────────────┼───┴────────────┼───┘
                              │                │
    Shared node chain:        ▼                ▼
                           [Node:20]──→[Node:10]──→ NULL
                              ↑
    v3: top ──→ [Node:30] ────┘

    v4 (branched from v1):
    v4: top ──→ [Node:99] ──→ [Node:10] ──→ NULL
                                  ↑
                            (same node as v1's)
```

- **Structural sharing:** Push creates one new node and points its `next` to the existing top of the source version. The old version's chain is untouched. This means versions share tail nodes.
- **Version array:** A `realloc`-growable array of `(top_ptr, size)` pairs (16 bytes each). Each version is an immutable snapshot — only the version array grows.
- **Pop without destruction:** Pop creates a new version pointing to `top->next` of the source. The source version's `top` pointer is unchanged.
- **Memory cost:** Each push allocates exactly one 16-byte node. Shared tails avoid duplication. `n` pushes from a single lineage use `n` nodes total, not `n²`.
- **Garbage collection challenge:** Freeing requires deduplication — nodes shared across versions must only be freed once. The implementation collects all unique node pointers before freeing.

## Uses

- **Undo/redo systems:** Text editors and IDEs maintain version history; each edit creates a new version, enabling arbitrary undo depth.
- **Functional programming runtimes:** Immutable data structures in Haskell, Clojure, and Scala use persistent trees with structural sharing.
- **Version control internals:** Git's object model is a persistent data structure — commits reference shared tree/blob objects.

## Complexities

| Operation     | Time   | Notes                              |
|:--------------|:-------|:-----------------------------------|
| Push (new ver)| O(1)   | Allocate 1 node + append version   |
| Pop (new ver) | O(1)   | Repoint top + append version       |
| Peek          | O(1)   | Read top of any version            |
| Access ver k  | O(1)   | Direct array index                 |
| **Space**     | **O(total ops)** | 1 node per push, 16B per version |
