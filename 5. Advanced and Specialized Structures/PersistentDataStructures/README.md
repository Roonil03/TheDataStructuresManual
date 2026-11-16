# Persistent Stack

`PersistentDataStructures.c` demonstrates a **fully persistent stack**: push and pop can branch from any retained version, and all older versions remain accessible. Version 0 is empty. Each successful modification appends a version and returns its index.

## API and ownership

- `pstack_push(ps, version, value)` creates one immutable node whose `next` points to the source version's top.
- `pstack_pop(ps, version, out_value)` writes the removed value and creates a version pointing to the shared tail. It does not modify or free the source node.
- `pstack_peek` and `pstack_size` read any version.
- Invalid version indices return `-1`; empty pop, null pop output, and empty peek also return `-1`. Peek's sentinel is ambiguous with a stored value of `-1`; use `pstack_size` to determine emptiness.

A growable array stores `(top, size, owns_top)` records. Only versions created by push own their newly allocated top node. Pop versions share existing nodes and own none. This lets `pstack_free` free each push-owned node exactly once in a single pass through versions, without traversing shared tails or deduplicating addresses. Individual versions cannot be deleted.

On a common ABI with 4-byte integers and 8-byte pointers, `PNode` and `PStack` are each 16 bytes; sizes and padding are platform-dependent. The version array reserves geometric capacity beyond its current length.

| Operation | Time |
| :-- | :-- |
| Push / pop | O(1) amortized; O(v) when the version array grows |
| Peek / size / version access | O(1) |
| Print one version | O(stack size) |
| Print all versions | O(v + sum of version sizes) |
| Destroy all versions | O(v) |
| Stored space | O(v + p) |

Here `v` is the number of versions and `p` the number of pushes. Allocation or version-capacity failure prints an error and terminates. The entire history remains allocated until `pstack_free`, even after a pop creates an empty version.

This example illustrates immutable structural sharing useful in undo histories and functional data structures. It implements a stack, rather than a general persistent container framework.

## Run

```sh
cc -std=c11 -Wall -Wextra -Wpedantic PersistentDataStructures.c -o /tmp/persistent-stack
/tmp/persistent-stack
```

The demonstration branches from an older version and prints unchanged history. It is not a comprehensive automated test suite.
