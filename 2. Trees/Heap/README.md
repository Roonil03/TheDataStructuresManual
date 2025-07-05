# Heaps
## Min‐Heap Data Structure Documentation

### Overview

A **min‐heap** is a complete binary tree where each parent node holds a value less than or equal to those of its children, ensuring the minimum element is always at the root. Internally, it is implemented as an array representing a complete tree without gaps, allowing efficient index calculations for parent and child relationships.

### Key Properties

- **Complete Tree**: All levels are fully filled except possibly the last, which is filled from left to right.
- **Heap Order**: Every node’s key is ≤ the keys of its children, so the smallest element resides at the root.
- **Array Representation**: A min‐heap of size *n* uses array indices such that for any node at index *i*, its children are at indices *2i+1* and *2i+2* and its parent at index *(i−1)//2*.


### Core Operations

1. **Insert (push)**
    - Place the new element at the end of the array.
    - “Heapify up” by repeatedly swapping it with its parent until the heap order is restored.
    - Runs in *O*(log *n*) time because the height of a complete binary tree is *O*(log *n*).
2. **Extract‐Min (pop)**
    - Remove the root (minimum).
    - Move the last element to the root position.
    - “Heapify down” by swapping it with the smaller of its children until heap order is restored.
    - Also runs in *O*(log *n*) time due to tree height.
3. **Build‐Heap**
    - Given an unordered array, it can be turned into a min‐heap in *O*(*n*) time by performing “heapify down” from the last non‐leaf node up to the root.

### Complexity Analysis

| Operation | Time Complexity |
| :-- | :-- |
| Build‐Heap | *O*(*n*) |
| Insert | *O*(log *n*) |
| Extract‐Min | *O*(log *n*) |
| Peek‐Min | *O*(1) |
| Space | *O*(*n*) |

### Implementation Details

- **Indexing**: 0‐based array indices simplify parent/child computations without explicit pointers.
- **Heapify Up**: Compare inserted node with its parent and swap if smaller, continuing until the root or correct position is reached.
- **Heapify Down**: Compare root with its children, swap with the smaller child, and recurse until no violation remains.
