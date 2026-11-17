# Treap

`Treap.c` combines a binary search tree on distinct integer keys with a max-heap on priorities supplied by `rand()`. Duplicate insertions leave the tree unchanged. Equal priorities are permitted.

## Implementation

Insertion follows the BST path and rotates a child upward when its priority exceeds its parent's. Deletion replaces a node with its only child, or rotates the child with the larger priority upward before continuing deletion. Search follows ordinary BST ordering. Every mutating operation returns the updated root, which the caller must retain.

`TreapNode` contains two integers and two child pointers, typically 24 bytes on a platform with 4-byte integers and 8-byte pointers. Each node is allocated individually. The demonstration seeds `rand` with 42; the exact generated priorities can differ between C libraries.

| Operation | Expected time | Worst time |
| :-- | :-- | :-- |
| Insert / delete / search | O(log n) | O(n) |
| Traversal / destruction | O(n) | O(n) |
| Stored space | O(n) | O(n) |

The expected height bound assumes sufficiently independent random priorities. This implementation uses the C library pseudorandom generator, offers no adversarial guarantee, and has no deterministic balancing rule. Recursive auxiliary space is O(h), with possible call-stack exhaustion when height approaches `n`. Allocation failure prints an error and terminates. `free_tree` releases the nodes.

Treaps are useful randomized search trees. Implicit indexing, split, and merge are related extensions and are not implemented here.

## Run

```sh
cc -std=c11 -Wall -Wextra -Wpedantic Treap.c -o /tmp/treap
/tmp/treap
```

The fixed demonstration prints inorder order, height, BST/heap checks, searches, and deletions. It is not a comprehensive automated test suite.
