# Cartesian Tree

A binary tree derived from an array where the root is the minimum element, and left/right subtrees are recursively built from the left/right subarrays. It satisfies both BST order on indices and min-heap order on values.

## Memory Mechanics

```
CTNode (32 bytes):
┌──────────┬──────────┬──────────┬──────────┐
│ value(4) │ index(4) │ left*(8) │right*(8) │
└──────────┴──────────┴──────────┴──────────┘

For input [3, 2, 6, 1, 9, 5, 7]:

            [1, idx=3]
           /          \
     [2, idx=1]    [5, idx=5]
     /     \        /     \
  [3,i=0] [6,i=2] [9,i=4] [7,i=6]
```

- **Stack-based O(n) construction:** Nodes are pushed onto a stack. When a smaller value arrives, nodes are popped (becoming left children) until the stack top is smaller or empty. This processes each element at most twice (push + pop).
- **No auxiliary arrays:** The tree is built in-place with individual `malloc` calls per node (32 bytes each). The stack is a temporary `n × 8 byte` pointer array, freed after construction.
- **Index preservation:** Each node stores its original array index, enabling range queries. Inorder traversal reproduces the original array order.
- **RMQ via tree structure:** Range minimum query over `[lo, hi]` traverses the tree, collecting all nodes with index in range and returning the minimum value.

## Uses

- **Range Minimum Queries (RMQ):** The Cartesian tree converts RMQ to Lowest Common Ancestor (LCA), enabling O(1) RMQ with O(n) preprocessing.
- **Treap construction:** Cartesian trees with random priorities are equivalent to treaps; the stack-based build is the batch construction algorithm.
- **Sorting visualization:** The tree structure reveals the recursive partitioning behavior of selection-sort-like algorithms.

## Complexities

| Operation      | Time   | Notes                           |
|:---------------|:-------|:--------------------------------|
| Build          | O(n)   | Stack-based, each element ≤ 2 ops |
| RMQ (naive)    | O(n)   | Full tree traversal             |
| RMQ (with LCA) | O(1)  | After O(n) Euler tour preprocessing |
| Inorder        | O(n)   | Reproduces original array       |
| **Space**      | **O(n)** | 32 bytes per node             |
