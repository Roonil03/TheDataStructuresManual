# Fibonacci Heap

`FibonacciHeap.c` implements a min-priority queue as a forest of heap-ordered trees. Roots and sibling groups are circular doubly linked lists. The heap stores a minimum-root pointer and a node count; nodes contain a key, child count, mark, and parent/child/sibling pointers.

## Operations and ownership

`make_heap` creates an empty heap. Insert a fresh, detached, singleton node from `make_node` with `fib_insert`; the heap then owns it. `H->min` provides constant-time minimum access and is null when empty. `fib_extract_min` frees the minimum node and returns its key. It returns `INT_MIN` on an empty heap, so callers must check `H->min` **before extraction** to distinguish emptiness from a valid `INT_MIN` key. Every integer key, including `INT_MIN`, is supported.

`fib_decrease_key(H, node, key)` requires a live handle belonging to that heap. A larger replacement key is ignored. Violating heap order cuts the node into the root list; marked ancestors trigger cascading cuts. `fib_delete` cuts and extracts the exact supplied node, including when other nodes also have `INT_MIN` keys. Extracted/deleted handles become invalid. Passing a node from another heap or inserting the same node twice is unsupported.

Extraction promotes the removed root's children, resets their parent/mark fields, and consolidates equal-degree roots. Its degree table has twice the bit width of `unsigned int`, plus one slot, sufficient for Fibonacci-tree degrees while the node count fits in `int`. The source exposes internal helpers for demonstration; they require valid heap invariants. There is no merge operation.

| Operation | Amortized time | Worst time |
| :-- | :-- | :-- |
| Make heap / insert / minimum | O(1) | O(1) |
| Decrease key | O(1) | O(n) |
| Extract minimum / delete | O(log n) | O(n) |
| Stored space | O(n) | O(n) |

These bounds assume O(1) allocation and exclude allocator internals. Cascading cuts use recursive stack space up to the current tree height. Node count must fit in `int`; allocation failure prints an error and terminates. The driver releases remaining nodes by extracting them, then frees the heap wrapper; applications must likewise release all owned nodes before freeing the wrapper.

## Run

```sh
cc -std=c11 -Wall -Wextra -Wpedantic FibonacciHeap.c -o /tmp/fibonacci-heap
/tmp/fibonacci-heap
```

Commands are `insert <key>`, `find_min`, `extract_min`, and `exit`, as whitespace-separated tokens. Empty lookup/extraction prints `empty`; integer keys must be complete decimal tokens with an optional sign and must fit in `int`. Arbitrarily many leading zeros are accepted. EOF, a missing/invalid insert operand, a command token longer than 15 bytes or containing a NUL byte, or `exit` ends the session and frees the remaining heap. Other unrecognized command tokens are ignored. The driver does not expose decrease-key/delete handles; those operations are available through the C functions.
