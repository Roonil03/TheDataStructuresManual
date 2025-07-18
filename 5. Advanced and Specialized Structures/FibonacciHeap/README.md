# Fibonacci Heap Documentation

## Overview

A **Fibonacci heap** is a collection of heap-ordered trees that together support a set of priority‐queue operations with very efficient amortized time bounds. Each tree in the heap obeys the **min‐heap property**: every parent’s key is no greater than any of its children. The heap maintains a direct pointer to the minimum element among all roots. Lazy restructuring (delaying work) yields improved amortized complexities compared to binary or binomial heaps.

## Key Properties

- **Heap-Ordered Forest**
A Fibonacci heap is a set of rooted trees arranged in a doubly linked circular root list.
- **Min Pointer**
A direct pointer `min` references the root node with the smallest key across all trees.
- **Node Structure**
Each node stores:
    - `key`
    - `degree` (number of children)
    - `mark` bit (whether it has lost a child)
    - Pointers: `parent`, `child`, `left`, `right`.
- **Lazy Consolidation**
After `extract-min`, trees are only consolidated on‐demand, achieving amortized time gains.


## Core Operations

| Operation | Description | Amortized Time |
| :-- | :-- | :-- |
| **make-heap** | Create and return an empty Fibonacci heap. | O(1) |
| **insert(x)** | Add a new node with key _x_ to the root list; update `min` if needed. | O(1) |
| **find-min()** | Return the key at `min` without removal. | O(1) |
| **merge(H1, H2)** | Concatenate the root lists of two heaps; update `min` to the smaller of the two minima. | O(1) |
| **extract-min()** | Remove and return the minimum node. Add its children to the root list, then consolidate trees of equal degree. | O(log n) |
| **decrease-key(x,k)** | Reduce the key of node _x_ to new value _k_ (≤ current key). If heap order is violated, cut and cascade cuts. | O(1) |
| **delete(x)** | Decrease key of _x_ to −∞, then `extract-min()`. | O(log n) |

## Complexity Analysis

- **Space**: O(n)
- **Amortized Time Bounds**:
    - `make-heap`, `insert`, `find-min`, `merge`, `decrease-key`: O(1)
    - `extract-min`, `delete`: O(log n)


## Implementation Details

1. **Node Allocation**
Allocate a node with pointers forming a one‐node circular list; initialize degree and mark to zero.
2. **Root List Management**
Root nodes form a circular, doubly linked list.
3. **Linking Trees**
In consolidation, pairwise link roots of equal degree—attach the larger‐key tree as a child of the smaller.
4. **Consolidation**
Use an auxiliary array indexed by degree; traverse root list, repeatedly linking trees until all roots have distinct degrees, then rebuild the root list and reset `min`.
5. **Cut and Cascading Cut**
On a decrease‐key that violates heap order, cut the node from its parent into the root list and mark the parent; if the parent was already marked, repeat recursively to the grandparent.
6. **Amortization**
The marking scheme ensures each node is cut at most once before its ancestor is cut, bounding the potential and yielding the stated amortized costs.
