# Treap

A randomized binary search tree where each node holds a key (BST-ordered) and a random priority (max-heap-ordered). Rotations maintain both invariants simultaneously, yielding expected O(log n) height.

## Memory Mechanics

```
TreapNode (32 bytes on 64-bit):
┌──────────┬──────────────┬──────────┬──────────┐
│ key (4B) │ priority (4B)│ left*(8B)│right*(8B)│
└──────────┴──────────────┴──────────┴──────────┘

Tree shape example (keys in BST order, priorities in heap order):
         [50, p=97]
        /           \
   [30, p=84]    [70, p=62]
   /     \          /
[20,p=33][40,p=71] [60,p=45]
```

- **Node allocation:** Each node is individually `malloc`'d (32 bytes). No contiguous array — tree shape is entirely pointer-driven.
- **Rotations:** `rotate_right` / `rotate_left` swap parent-child pointers to bubble higher-priority nodes upward while preserving BST order. These are O(1) pointer reassignments.
- **Randomized balance:** Priorities are assigned via `rand()` at insertion. Expected tree height is O(log n), equivalent to a random BST, without needing deterministic balancing rules.
- **Deletion:** The target node is rotated downward (choosing the child with higher priority) until it becomes a leaf, then freed.

## Uses

- **Randomized search trees:** Used where AVL/RB-tree complexity is undesirable but balanced performance is needed.
- **Implicit treaps:** Array-backed sequences with O(log n) split/merge for text editors and rope data structures.
- **Randomized priority queues:** Combined key-ordered search with priority-ordered extraction.

## Complexities

| Operation | Expected   | Worst  | Notes                        |
|:----------|:-----------|:-------|:-----------------------------|
| Search    | O(log n)   | O(n)   | BST search                   |
| Insert    | O(log n)   | O(n)   | BST insert + rotations up    |
| Delete    | O(log n)   | O(n)   | Rotate down to leaf + free   |
| **Space** | **O(n)**   |        | 32 bytes per node            |
