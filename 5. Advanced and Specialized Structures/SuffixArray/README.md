# Suffix Array

`SuffixArray.c` indexes the `n` nonempty suffixes of a copied, null-terminated byte string. `sa[i]` is the starting text index of the ith lexicographically sorted suffix; `rank` is its inverse. `lcp[i]` is the longest common prefix length of suffixes at sorted positions `i - 1` and `i`, with `lcp[0] = 0` when `n > 0`.

For `banana`, the arrays are:

```text
sa:   5 3 1 0 4 2
rank: 3 2 5 1 4 0
lcp:  0 1 3 0 0 2
```

## Implementation and API

Construction uses standard C `qsort` on temporary `(suffix pointer, index)` records, comparing suffixes with `strcmp`; suffix contents are not duplicated. Kasai's algorithm builds the LCP array. An empty input is supported and has zero indexed suffixes. `sa_create(NULL)` or a length exceeding the representable/index-allocation limits returns `NULL`. Allocation failure prints an error and terminates.

`sa_search(s, pattern)` returns any matching starting index or `-1`. `sa_count` counts all starting positions, including overlapping occurrences, using two binary searches. An empty pattern matches every indexed suffix: its count is `n`, and search returns an arbitrary suffix position if `n > 0`; the trailing empty suffix at index `n` is not represented. Search/count require null-terminated patterns; null arguments return `-1`/`0` respectively. Embedded null bytes cannot be indexed.

| Operation | Time |
| :-- | :-- |
| Construction comparisons | O(n) per comparison; typically O(n² log n) total with O(n log n) sorting |
| LCP construction | O(n) |
| Pattern search / count | O(m log n), or O(log n) for an empty pattern |
| Destruction | O(1) allocator calls |
| Stored and temporary space | O(n) |

`qsort`'s exact complexity is C-library-dependent; ISO C does not specify a worst-case sorting bound. `m` is pattern length. Stored space includes the copied text, three integer arrays, and the wrapper; construction additionally allocates O(n) temporary suffix records. `sa_free` frees all owned allocations and accepts `NULL`.

Suffix arrays support substring lookup and repeated-substring analysis; linear-time construction and LCA/RMQ acceleration are not implemented.

## Run

```sh
cc -std=c11 -Wall -Wextra -Wpedantic SuffixArray.c -o /tmp/suffix-array
/tmp/suffix-array
```

The fixed demonstration indexes `banana` and prints several searches/counts. It is not a comprehensive automated test suite.
