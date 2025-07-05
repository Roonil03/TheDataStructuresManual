# B-Tree

## Introduction to B-Trees
A B-Tree is a **self-balancing tree data structure** that maintains sorted data and allows efficient search, sequential access, insertion, and deletion operations. Unlike binary trees, B-Trees are optimized for systems that read and write large blocks of data, making them fundamental for **database systems** and **file systems**. Each node can contain multiple keys and have more than two children, which minimizes disk I/O operations by reducing tree height.

## Key Properties
1. **Order `m`**: Defines maximum children per node (max `m` children, `m-1` keys)
2. **Balance Maintenance**: 
   - All leaf nodes reside at the same level
   - Root contains at least 1 key (unless empty)
   - Internal nodes have between `⌈m/2⌉` and `m` children
3. **Node Capacity**:
   - Minimum keys: `⌈m/2⌉ - 1` (except root)
   - Maximum keys: `m - 1`
4. **Sorted Order**: Keys in each node are stored in ascending order

## Core Operations
### 1. Search
- Starts at root node
- Compares target key with node keys
- Recursively traverses to appropriate child
- **Time Complexity**: O(log n)

### 2. Insertion
1. Traverse to appropriate leaf node
2. Insert key while maintaining sorted order
3. If node overflows (`keys > m-1`):
   - Split node into two
   - Promote median key to parent
   - Recursively check parent overflow
- **Time Complexity**: O(log n)

### 3. Deletion
1. Locate key to delete
2. Handle cases:
   - **Leaf node**: Remove key, rebalance if underflow
   - **Internal node**: Replace with predecessor/successor
3. Rebalance underflow nodes via:
   - Key borrowing from siblings
   - Node merging when necessary
- **Time Complexity**: O(log n)

## Complexity Analysis
| Operation | Time Complexity |
|-----------|-----------------|
| Search    | O(log n)        |
| Insert    | O(log n)        |
| Delete    | O(log n)        |
| Space     | O(n)            |

## Implementation Considerations
- **Node Structure**: Stores keys and child pointers
- **Split Logic**: Median key promotion during insertion
- **Rebalancing**: Borrow/merge operations during deletion
- **Concurrency**: Requires node-level locking in multi-threaded environments
- **Disk Optimization**: Node size aligned with disk block size (typically 4KB)

## B-Tree Variants
1. **B+ Tree**:
   - Keys stored only in leaf nodes
   - Leaf nodes linked sequentially
   - Enhanced performance for range queries
2. **B* Tree**:
   - Nodes kept ≥2/3 full
   - Reduced split frequency
3. **Concurrent B-Trees**:
   - Specialized versions (e.g., Marlin)
   - Optimized for RDMA operations in disaggregated memory

## Why B-Trees Excel
1. **Shallow Height**: Logarithmic growth even with massive datasets
2. **High Branching Factor**: Minimizes disk seeks
3. **Predictable Performance**: Guaranteed balance for consistent operations
4. **Storage Efficiency**: Nodes typically 50-100% full
5. **Range Query Optimization**: Sequential access to leaf nodes

> B-Trees remain the **gold standard** for disk-based data structures, enabling modern databases to manage billions of records with sub-millisecond access times. Their design elegantly balances insertion/deletion efficiency with query performance, making them indispensable in data-intensive applications.
