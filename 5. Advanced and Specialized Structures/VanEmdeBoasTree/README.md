# van Emde Boas Tree

`vanEmdeBoasTree.c` maintains a set of integers in the fixed universe `[0, u - 1]`, where `u >= 2` is a representable positive power of two. `vEB_create` returns `NULL` for other universe sizes. The example driver uses `u = 16`.

## Structure

Each node stores its universe size, minimum/maximum (`-1` when empty), cached lower/upper sizes, a summary, and cluster pointers. The minimum is stored separately from the clusters. For `u = 2^b`, clusters have universe size `lower = 2^floor(b/2)` and their count is `upper = 2^ceil(b/2)`. The summary has universe `upper`. These unequal halves are essential when `b` is odd: for `u = 8`, there are four clusters of size two.

A key is split as `high = x / lower`, `low = x % lower`, and reconstructed as `high * lower + low`. Operations use the cached sizes, avoiding floating-point rounding and repeated square-root/logarithm calculations.

## API

- `vEB_insert` ignores duplicates and out-of-universe keys.
- `vEB_delete` ignores absent and out-of-universe keys. Deleting the only present key makes the set empty.
- `vEB_member` returns false for an empty tree, a null tree, or an out-of-universe key.
- `vEB_successor` returns the smallest stored key strictly greater than its argument, or `-1` if none exists.
- `vEB_predecessor` returns the largest stored key strictly smaller than its argument, or `-1` if none exists. Both ordering queries accept any `int`, including values outside the universe.
- Read `min`/`max` directly for extrema; `vEB_free` recursively releases all allocations and accepts `NULL`.

Insert/delete check membership once before their internal mutation, preserving set semantics without repeated checks at every recursive level.

| Operation | Time |
| :-- | :-- |
| Member / insert / delete / successor / predecessor | O(log log u) |
| Minimum / maximum | O(1) |
| Construction / destruction | O(u) |
| Stored space | O(u) |
| Operation recursion | O(log log u) |

All summary/cluster trees are allocated eagerly, so large universes can be impractical despite fast queries. Allocation failure prints an error and terminates. This implementation is useful for studying bounded-integer sets and their order queries; it is not a sparse-universe allocation scheme.

## Run

```sh
cc -std=c11 -Wall -Wextra -Wpedantic vanEmdeBoasTree.c -o /tmp/veb-tree
/tmp/veb-tree
```

Commands are `i <x>` (insert), `d <x>` (delete), `m <x>` (membership), `s <x>` (successor), `r <x>` (predecessor), `p` (print min/max), and `q` (quit), as whitespace-separated tokens. Commands must be single characters; combined tokens such as `i5` and `pp` are invalid. The driver reports `Out of range` for invalid insert keys. Keys/arguments must be complete decimal tokens with an optional sign and must fit in `int`; arbitrarily many leading zeros are accepted. EOF, an invalid/missing integer operand, a command token longer than one byte or containing a NUL byte, or `q` ends the session and frees the tree. Other unrecognized single-character commands are ignored.
