# Interval Tree

An augmented BST where each node stores an interval `[low, high]` and a `max` field tracking the maximum endpoint in its subtree. Enables efficient overlap queries.

## Memory Mechanics

```
ITNode (24 bytes):
┌──────────┬──────────┬──────────┬──────────┬──────────┐
│ low (4B) │ high (4B)│ max (4B) │ left*(8B)│right*(8B)│
└──────────┴──────────┴──────────┴──────────┴──────────┘

Tree ordered by 'low' endpoint (BST), 'max' propagated upward:

         [15,20] max=40
        /              \
   [10,30] max=30   [17,19] max=40
   /     \               \
[5,20]  [12,15]       [30,40]
max=20  max=15        max=40
```

- **Augmented field:** `max = max(high, left->max, right->max)` is recomputed bottom-up after every insert/delete. This costs O(1) per node on the path.
- **Overlap pruning:** When searching for overlaps with query `[lo,hi]`: if `left->max < lo`, the entire left subtree can be skipped. This prunes the search space based on the augmented max.
- **BST ordering:** Nodes are ordered by their `low` endpoint. This means intervals with the same `low` value follow insertion order into the right subtree.
- **Per-node allocation:** Each node is individually `malloc`'d at 24 bytes (with padding, typically 32 bytes due to alignment).

## Uses

- **Scheduling systems:** Detect conflicts in meeting/resource booking by finding overlapping time intervals.
- **Computational geometry:** Sweep-line algorithms query active intervals during geometric intersection tests.
- **Genomics:** Map reads to reference genome positions by querying overlapping coordinate ranges.

## Complexities

| Operation       | Average    | Worst  | Notes                           |
|:----------------|:-----------|:-------|:--------------------------------|
| Insert          | O(log n)   | O(n)   | BST insert + max update         |
| Delete          | O(log n)   | O(n)   | BST delete + max update         |
| Search Overlap  | O(log n)   | O(n)   | Single result, pruned by max    |
| All Overlaps    | O(k log n) | O(kn)  | k = number of results           |
| **Space**       | **O(n)**   |        | 24-32 bytes per node            |
