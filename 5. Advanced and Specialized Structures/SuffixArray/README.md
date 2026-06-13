# Suffix Array

A sorted array of all suffixes of a string, represented as an integer array of starting indices. Paired with an LCP (Longest Common Prefix) array for efficient substring operations.

## Memory Mechanics

```
SuffixArray struct (40 bytes):
┌──────────┬──────────┬──────────┬──────────┬──────────┐
│ text*(8) │  n (4B)  │  sa*(8B) │rank*(8B) │ lcp*(8B) │
└────┬─────┴──────────┴────┬─────┴────┬─────┴────┬─────┘
     │                     │          │          │
     ▼                     ▼          ▼          ▼
  "banana\0"          [5,3,1,0,4,2] [3,2,5,0,4,1] [0,1,3,0,0,2]
                       SA array      Rank array    LCP array

For "banana":
SA[0]=5 → "a"        LCP[0]=0
SA[1]=3 → "ana"      LCP[1]=1  (shared "a" with prev)
SA[2]=1 → "anana"    LCP[2]=3  (shared "ana" with prev)
SA[3]=0 → "banana"   LCP[3]=0
SA[4]=4 → "na"       LCP[4]=0
SA[5]=2 → "nana"     LCP[5]=2  (shared "na" with prev)
```

- **SA array:** `n × 4 bytes`. Each entry is an integer index into the text. Suffixes are not stored explicitly — `text + sa[i]` gives the suffix string. This avoids O(n²) storage.
- **Rank array:** `n × 4 bytes`. Inverse of SA: `rank[i]` = position of suffix starting at index `i` in the sorted order.
- **LCP array:** `n × 4 bytes`. Built via Kasai's algorithm in O(n) using the rank array. `lcp[i]` = length of longest common prefix between `SA[i]` and `SA[i-1]`.
- **Pattern search:** Binary search on SA comparing `text + sa[mid]` with pattern via `strncmp`. O(m log n) where m = pattern length.

## Uses

- **Full-text search:** Genome databases (BLAST alternatives) use suffix arrays for substring matching across multi-gigabyte sequences.
- **Data compression:** BWT (Burrows-Wheeler Transform) is derived from the suffix array for use in bzip2-style compressors.
- **Longest repeated substring:** Found by scanning the LCP array for the maximum value.

## Complexities

| Operation               | Time         | Notes                        |
|:------------------------|:-------------|:-----------------------------|
| Construction (naive)    | O(n² log n)  | Sort + strcmp per comparison  |
| Construction (SA-IS)    | O(n)         | Linear-time algorithm        |
| LCP Construction        | O(n)         | Kasai's algorithm            |
| Pattern Search          | O(m log n)   | Binary search + strncmp      |
| Pattern Count           | O(m log n)   | Two binary searches          |
| **Space**               | **O(n)**     | 3 × 4n bytes arrays + text   |
