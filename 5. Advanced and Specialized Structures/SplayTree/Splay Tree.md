# Splay Tree

Overview
========
A **Splay Tree** is a self-adjusting binary search tree that moves accessed elements to the root through a process called *splaying*. This adaptive strategy improves access times for frequently used keys by exploiting *locality of reference*.

Properties
==========

- Each node contains a key and pointers to its left and right children.
- No explicit balance information (e.g., heights or colors) is stored.
- After any access (search, insert, or delete), the accessed node is splayed to the root.

Core Operations
===============

1. **Splaying**
Repeatedly applies tree rotations to move a target node to the root.
    - *Zig*: Single rotation when the node is a child of the root.
    - *Zig-Zig*: Double rotation when the node and its parent are both left or both right children.
    - *Zig-Zag*: Double rotation when the node is a left child and its parent is a right child, or vice versa.
2. **Search**

3. Splay the node with the given key.
4. If found at the root, return the tree; otherwise, the key is absent, and the last accessed node remains root.
1. **Insert**

2. If the tree is empty, create a new node as root.
3. Otherwise, splay the tree on the key.
4. If the key exists, return the tree.
5. Create a new node and attach the left and right subtrees of the old root appropriately, making it the new root.
1. **Delete**

2. Splay the tree on the key to bring it to the root.
3. If the root’s key ≠ target, the key is absent—return the tree.
4. Otherwise, remove the root by splaying its left subtree on the same key and reattach the right subtree.

Time Complexity
===============


| Operation | Amortized Case | Worst Case |
| :-- | :-- | :-- |
| Search | O(log n) | O(n) |
| Insert | O(log n) | O(n) |
| Delete | O(log n) | O(n) |

- **Amortized Analysis**: A sequence of M operations on an initially empty tree with N inserted nodes takes O((M + N) log N) total time.

Advantages
==========

- **Adaptive Performance**: Frequently accessed elements are quicker to reach.
- **Space Efficiency**: No extra balance data per node.
- **Simplicity**: Easier to implement than strictly balanced trees.

Disadvantages
=============

- **Poor Worst-Case**: Single operations can degrade to O(n) if splaying repeatedly unbalancing the tree.
- **Not Cache-Aware**: May perform poorly on uniformly random access patterns compared to strictly balanced trees.

Applications
============

- **Self-Adjusting Heaps**: Basis for pairing heaps.
- **Cache Simulations**: Emulates LRU caching behavior.
- **Network Routers**: Speeding up IP route lookups.
- **Memory Management**: Underlies certain garbage collectors and virtual memory systems where adaptive access is beneficial.