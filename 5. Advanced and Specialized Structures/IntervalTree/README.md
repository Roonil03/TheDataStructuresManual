# Interval Tree

`IntervalTree.c` implements an unbalanced binary search tree of closed integer intervals `[low, high]`. Each node stores the maximum high endpoint in its subtree. Touching endpoints count as overlapping.

## Implementation

`it_insert(root, low, high)` returns the updated root. Lower endpoints order the tree: smaller values go left, equal values go right. Exact duplicate intervals are stored separately. `it_delete` removes one exact `(low, high)` match and updates subtree maxima. Insertion and deletion with `low > high` leave the tree unchanged.

`it_search` returns any overlapping node or `NULL`. It follows one path, using the left subtree's maximum endpoint to decide which branch can contain an overlap. An inverted query returns `NULL`.

`it_search_all(root, low, high, results)` returns the number of overlapping intervals and writes their **low endpoints only** to `results`. The caller must supply room for at least as many integers as there are nodes; the API has no capacity argument. Duplicate intervals produce duplicate results. An inverted query or null output pointer returns zero. Traversal prunes left subtrees using their maxima and right subtrees using the BST ordering, but can still visit all nodes.

`ITNode` has three integers and two pointers, typically 32 bytes with 4-byte integers and 8-byte pointers, including alignment padding. Exact layout is ABI-dependent.

| Operation | Time |
| :-- | :-- |
| Insert / delete / find one overlap | O(h), worst O(n) |
| Find all overlaps / inorder / destruction | O(n) worst case |
| Stored space | O(n) |
| Recursive auxiliary space | O(h) |

There is no balancing, so ordered insertions can produce height `h = n`. Recursive operations can exhaust the call stack on deep trees. Allocation failure prints an error and terminates. Pass the final root to `it_free` when done.

Interval trees support scheduling conflict detection, coordinate overlap queries, and similar inclusive-range searches. Balanced variants provide stronger height bounds than this example.

## Run

```sh
cc -std=c11 -Wall -Wextra -Wpedantic IntervalTree.c -o /tmp/interval-tree
/tmp/interval-tree
```

The fixed demonstration inserts intervals, searches for overlaps, and deletes one interval. It is not a comprehensive automated test suite.
