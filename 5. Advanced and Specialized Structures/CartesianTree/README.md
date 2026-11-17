# Cartesian Tree

`CartesianTree.c` builds a min Cartesian tree from an integer array. Inorder traversal follows original array indices, and each parent value is no larger than its children's values. Equal values retain the earlier element above later equal elements because construction pops only strictly larger values.

## Implementation

`ct_build(arr, n)` creates a tree using a temporary monotonic stack of node pointers. Each node is pushed once and popped at most once. The input array is copied into separately allocated nodes and remains unchanged. An empty array creates a tree with a null root; a negative length or a null array with positive length returns `NULL`.

`CTNode` stores `value`, `index`, and two child pointers (typically 24 bytes on an ABI with 4-byte integers and 8-byte pointers; use `sizeof` for the target platform). The temporary construction stack uses `n * sizeof(CTNode *)` bytes and is freed before returning.

The demonstration's `rmq(root, lo, hi)` visits every node, returning a node with the smallest value whose index is inside the inclusive range, or `NULL` if none exists. It does not validate the bounds against the original array size. An LCA-based constant-time RMQ index is a possible extension and is not implemented.

| Operation | Time | Auxiliary space |
| :-- | :-- | :-- |
| Build | O(n) | O(n) temporary stack |
| Range minimum query | O(n) | O(h) recursion |
| Traversal / destruction | O(n) | O(h) recursion |
| Stored tree | — | O(n) |

Here `h` is tree height, which can be `n` for monotonic input. Recursive helpers can exhaust the call stack on very deep trees. Allocation failure prints an error and terminates the process. The caller frees both the node tree and its `CartesianTree` wrapper.

Cartesian trees are useful for range minimum indexing and for relating array order to heap priorities.

## Run

```sh
cc -std=c11 -Wall -Wextra -Wpedantic CartesianTree.c -o /tmp/cartesian-tree
/tmp/cartesian-tree
```

The fixed demonstration prints the tree, its invariants, and three range minima. Its output is illustrative rather than a comprehensive automated test suite.
