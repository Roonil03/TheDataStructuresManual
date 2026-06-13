# Hash Map

A key-value associative container that maps keys to values using a hash function. Collisions are resolved via separate chaining (linked lists per bucket).

## Memory Mechanics

```
HashMap struct (16 bytes):
┌────────────┬──────────┬──────────────────┐
│  cap (4B)  │ size (4B)│ buckets_ptr (8B) │
└────────────┴──────────┴────────┬─────────┘
                                 │
                                 ▼
Bucket array (cap × 8 bytes, array of pointers):
┌──────────┬──────────┬──────────┬──────────┬─────┐
│bucket[0] │bucket[1] │bucket[2] │bucket[3] │ ... │
└──────────┴────┬─────┴──────────┴──────────┴─────┘
                │
                ▼
             Entry (C: key_ptr + val + next)
             ┌──────────┬──────────┬──────────┐
             │ key* (8) │ val (4)  │ next*(8) │
             └──────────┴──────────┴────┬─────┘
                                        ▼
                                     Entry ──→ NULL
```

- **Hash function (djb2):** `h = ((h << 5) + h) + c` for each character. Result is modded by capacity to select a bucket index.
- **Bucket lookup:** `buckets_ptr + hash(key) * 8` gives the head pointer for the chain. O(1) pointer dereference.
- **Collision chains:** Each bucket is a singly-linked list of Entry nodes. On collision, a new node is prepended (O(1) insert). Lookups traverse the chain comparing keys via `strcmp`.
- **Key ownership:** Keys are `strdup`'d on insert — the map owns its own copy. On removal, both the key string and the Entry are freed.
- **Load factor:** With `n` entries and `cap` buckets, average chain length is `n/cap`. No automatic rehashing in this implementation.

## Uses

- **Symbol tables:** Compilers and interpreters map variable names to memory addresses/types.
- **Caching / memoization:** Store computed results keyed by input parameters for O(1) retrieval.
- **Configuration stores:** Map string keys to values for application settings, environment variables.

## Complexities

| Operation  | Average | Worst    | Notes                          |
|:-----------|:--------|:---------|:-------------------------------|
| Put        | O(1)    | O(n)     | Amortized; worst = full chain  |
| Get        | O(1)    | O(n)     | Chain traversal on collision   |
| Remove     | O(1)    | O(n)     | Chain traversal + unlink       |
| Contains   | O(1)    | O(n)     | Same as Get                    |
| **Space**  | **O(n + cap)** | | 8·cap bytes buckets + entry nodes |
