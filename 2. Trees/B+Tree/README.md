# B+ Tree

## Included programs

`B+Tree.c` reads a nonnegative key count followed by that many integers. It stores distinct keys in an order-3 B+ tree, propagates leaf/internal splits to the root, links leaves, and prints keys in ascending order. Each node holds at most two keys after insertion; arrays reserve a temporary overflow slot. Search is used internally to find a leaf; deletion and a public range-query interface are not implemented.

`B+Tree.asm` reads the same count-and-keys format and retains all values, including duplicates. It builds an order-3 B+ tree, recursively propagates leaf/internal splits, and traverses the linked leaves to print sorted output. Every node holds one or two keys after insertion, all leaves have equal depth, and internal keys are copies of the smallest keys in their right subtrees. Both implementations free their nodes before returning. Search, deletion, and a public range-query interface are not implemented in the assembly example.

For this fixed order, both programs take O(log n) time per insertion, O(n) time for a full leaf traversal, and O(n) space. The general operations below include search and deletion as background.

Build from this directory (outputs stay in `/tmp`):

```sh
gcc -std=c11 -Wall -Wextra "B+Tree.c" -o /tmp/bplustree
nasm -f elf64 "B+Tree.asm" -o /tmp/tree.o
gcc -no-pie /tmp/tree.o -o /tmp/tree-asm
```

## Overview of B+ Trees
A **B+ Tree** is a specialized self-balancing tree structure optimized for systems that handle large volumes of data with frequent read/write operations. Designed as an extension of B-Trees, B+ Trees excel in database indexing and file systems where disk I/O minimization is critical. Unlike standard B-Trees, B+ Trees store all data in leaf nodes with internal nodes serving solely as index navigators, enabling highly efficient range queries and sequential access.

## Key Properties
1. **Structure Rules**:
   - All data records reside exclusively in **leaf nodes**; internal separator keys may duplicate leaf keys
   - Internal nodes contain only keys and child pointers
   - Leaf nodes are linked sequentially for ordered traversal
   - A non-leaf root has between 2 and `m` children; an empty tree may have no root (where `m` = tree order)

2. **Capacity Constraints**:
   - Internal nodes: `⌈m/2⌉` to `m` children
   - Leaf capacity depends on the chosen convention; this order-3 implementation stores 1–2 keys per non-root leaf
   - Root exempt from minimum constraints

3. **Balance Guarantee**:
   - All leaf nodes exist at the same depth
   - Automatic rebalancing after insertions/deletions
   - Height grows logarithmically with data volume

## Core Operations
### 1. Search
```python
def search(key, node):
    if node.is_leaf:
        return binary_search(node.keys, key)
    else:
        idx = find_child_index(node.keys, key)
        return search(key, node.children[idx])
```
- **Time Complexity**: O(logm n)
- Traverses internal nodes via key comparisons
- Terminates at relevant leaf node

### 2. Insertion
1. Traverse to target leaf node
2. Insert key while maintaining sorted order
3. **Leaf overflow handling**:
   - Split leaf into two nodes
   - Promote smallest key of right node to parent
   - Link new leaf to neighbor leaves
4. Propagate splits upward if internal nodes overflow

### 3. Deletion
1. Locate key in leaf node
2. Remove key while preserving order
3. **Underflow handling**:
   - Borrow keys from adjacent sibling if possible
   - Merge with sibling if below `⌈m/2⌉` threshold
   - Remove parent key if merge occurs
4. Rebalance tree upward from deletion point

## Complexity Analysis

The O(log_m n) operation descriptions count tree levels (node accesses). The CPU bounds below include linear scans and shifts within a node; with the fixed order 3 used here, they reduce to O(log n).

| Operation | Time Complexity | Space Complexity |
|-----------|-----------------|------------------|
| Search    | O(m log_m n) with linear node scans | O(1) |
| Insert    | O(m log_m n) | O(log_m n) recursion |
| Delete    | O(m log_m n) | O(log_m n) recursion |
| Range Query | O(m log_m n + k) | O(1)        |

*Where `n` = number of elements, `m` = tree order, `k` = keys in range*

## Implementation Considerations
- **Node Structure**:
  ```c
  struct BPlusNode {
      bool is_leaf;
      int num_keys;
      int keys[m-1];
      union {
          struct BPlusNode* children[m]; // Internal nodes
          struct {
              void* data_pointers[m];
              struct BPlusNode* next; // Leaf nodes
          };
      };
  };
  ```
- **Disk Optimization**:
  - Node size = disk block size (typically 4KB)
  - Minimize disk seeks through high branching factor
- **Concurrency**:
  - Implement node-level locking for multi-threaded environments
  - Versioning for snapshot isolation

## Advantages
1. **Range Query Efficiency**: Sequential leaf traversal enables O(k) range scans
2. **Higher Fanout**: More keys per node than B-Trees (no data in internal nodes)
3. **Stable Performance**: Guaranteed O(logm n) operations
4. **Disk I/O Reduction**: 3-4x fewer disk accesses than B-Trees
5. **Predictable Growth**: Height increases only when root splits

## Disadvantages
1. **Insertion Overhead**: More frequent splits than B-Trees
2. **Redundant Keys**: Keys appear in both internal and leaf nodes
3. **Implementation Complexity**: ~40% more complex than B-Tree implementation
4. **Point Query Cost**: Slightly slower than B-Trees for single-key lookups

## Real-World Applications
1. **Database Systems**:
   - MySQL InnoDB indexes
   - PostgreSQL table indexing
   - Oracle database engines
2. **File Systems**:
   - NTFS (Windows)
   - ReiserFS (Linux)
   - HFS+ (macOS)
3. **Time-Series Databases**:
   - InfluxDB timestamp indexing
   - Prometheus metric storage
4. **Blockchain Systems**:
   - Ethereum state trie optimization
   - IPFS content addressing

## B+ Tree vs B-Tree Comparison
| Feature          | B+ Tree                     | B-Tree                  |
|------------------|-----------------------------|-------------------------|
| **Data Storage** | Only in leaf nodes          | All nodes               |
| **Leaf Linkage** | Linked sequential access    | No leaf connections     |
| **Height**       | Lower for same data volume  | Slightly higher         |
| **Range Queries**| Optimal (O(k))             | O(log n + k) with ordered traversal|
| **Point Queries**| Slightly slower            | Faster                  |
| **Disk Usage**   | More efficient              | Less efficient          |

## Conclusion
B+ Trees represent the **gold standard for disk-based indexing**, offering unparalleled efficiency for range queries and sequential access patterns. Their design elegantly balances insertion/deletion costs with query performance, making them indispensable in database systems and file storage where disk I/O dominates performance. While more complex to implement than B-Trees, their performance advantages in data-intensive applications justify the implementation effort. For systems requiring ordered data traversal with logarithmic operation guarantees, B+ Trees remain the optimal choice decades after their invention.
