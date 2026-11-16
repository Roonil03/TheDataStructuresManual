# TheDataStructuresManual
This repository contains the most used and important Data Structures in an attempt to understand how they work in the memory.

<div align="center">

[![GitHub license](https://img.shields.io/github/license/Roonil03/TheDataStructuresManual?color=green&style=flat-square)](https://github.com/Roonil03/TheDataStructuresManual/blob/main/LICENSE)

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/Roonil03/TheDataStructuresManual?color=blue&logo=github&style=flat-square)](https://github.com/Roonil03/TheDataStructuresManual/releases)
[![GitHub repo size](https://img.shields.io/github/repo-size/Roonil03/TheDataStructuresManual?style=flat-square)](https://github.com/Roonil03/TheDataStructuresManual)

[![GitHub last commit](https://img.shields.io/github/last-commit/Roonil03/TheDataStructuresManual?color=orange&style=flat-square)](https://github.com/Roonil03/TheDataStructuresManual/commits/main)
[![GitHub language count](https://img.shields.io/github/languages/count/Roonil03/TheDataStructuresManual?color=yellowviolet&style=flat-square)](https://github.com/Roonil03/TheDataStructuresManual)

</div>

---

## C input conventions

Interactive integer input in the linear and tree examples, plus Fibonacci heap, splay tree, and van Emde Boas tree, uses [`common/input.h`](./common/input.h). Each integer is a complete whitespace-separated decimal token: an optional `+` or `-`, followed by one or more ASCII digits. Values must fit in `int`; arbitrary leading zeros are accepted. Each driver also checks its own count, coordinate, or index bounds. Malformed tokens, including embedded NUL bytes and numeric suffixes, stop input before that token changes the data structure. EOF ends input and releases allocated storage.

Word and command readers enforce the byte limits documented with each example and reject embedded NUL bytes. The C R-tree accepts complete finite floating-point coordinate tokens of at most 127 bytes and rejects range errors.

## Repository Index

Select a module category below to view the individual algorithms, memory configurations, and language implementations:

### 1. Linear Structures
* **Arrays & Matrices**
    * [Arrays](./1.%20Linear/Arrays/)
    * [Matrix](./1.%20Linear/Matrix/)
    * [Sparse Matrix](./1.%20Linear/SparseMatrix/)
* [Linked lists (singly, doubly and circular)](./1.%20Linear/LinkedLists/)
* **Sequential Access**
    * [Stack](./1.%20Linear/Stacks/)
    * [Queues (Simple, Circular, Priority, Deque)](./1.%20Linear/Queues/)

### 2. Trees
* **Binary & Self-Balancing Search Trees**
    * [Binary Tree](./2.%20Trees/BinaryTree/)
    * [Binary Search Trees (BST)](./2.%20Trees/BinarySearchTree/)
    * [AVL Trees](./2.%20Trees/AVLTree/)
    * [Red-Black Trees](./2.%20Trees/RBTree/)
* [Min and max heaps](./2.%20Trees/Heap/)
* **String & Range Query Structures**
    * [Segment Trees](./2.%20Trees/SegmentTree/)
    * [Fenwick Trees (BIT)](./2.%20Trees/FenwickTree/)
    * [Trie](./2.%20Trees/Trie/)
    * [Suffix Tree](./2.%20Trees/SuffixTree/)
* **Multi-Dimensional & Multi-Way Trees**
    * [B-tree](./2.%20Trees/BTree/)
    * [B+ tree](./2.%20Trees/B+Tree/)
    * [KD Tree](./2.%20Trees/KDTree/)
    * [Quad Tree](./2.%20Trees/QuadTree/)
    * [Octree](./2.%20Trees/Octrees/)
    * [R-Tree](./2.%20Trees/RTrees/)

### 3. Graphs
* [Digraph](./3.%20Graphs/Digraph/)
* [Adjacency Matrix](./3.%20Graphs/AdjacencyMatrix/)
* [Adjacency List](./3.%20Graphs/AdjacencyList/)
* [Doubly Connected Edge List (DCEL)](./3.%20Graphs/DoubleConnectedEdgeList/)

### 4. Hash-Based
* [Hash Table](./4.%20Hash-Based/HashTable/)
* [Hash Map](./4.%20Hash-Based/HashMap/)
* [Hash Set](./4.%20Hash-Based/HashSet/)

### 5. Advanced & Specialized Structures
* [Fibonacci Heap](./5.%20Advanced%20and%20Specialized%20Structures/FibonacciHeap/)
* [Van Emde Boas Tree](./5.%20Advanced%20and%20Specialized%20Structures/VanEmdeBoasTree/)
* [Splay Tree](./5.%20Advanced%20and%20Specialized%20Structures/SplayTree/)
* [Treap](./5.%20Advanced%20and%20Specialized%20Structures/Treap/)
* [Suffix Array](./5.%20Advanced%20and%20Specialized%20Structures/SuffixArray/)
* [Cartesian Tree](./5.%20Advanced%20and%20Specialized%20Structures/CartesianTree/)
* [Interval Tree](./5.%20Advanced%20and%20Specialized%20Structures/IntervalTree/)
* [Persistent Data Structures](./5.%20Advanced%20and%20Specialized%20Structures/PersistentDataStructures/)
