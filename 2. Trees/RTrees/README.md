# R-Tree Data Structure

## Included programs

`rTree.c` offers insertion, inclusive-overlap range search, display, and exit. Rectangles require finite coordinates with `xmin <= xmax` and `ymin <= ymax`; zero-area rectangles and boundary intersections are accepted. Nodes hold at most four entries, with at least two in each non-root node. Insertion chooses a child by area enlargement, refreshes covering rectangles, and propagates splits through the root. Splits use quadratic seed selection and greedy assignment subject to minimum occupancy. Deletion and updates below are not implemented.

Menu choices and IDs use complete signed 32-bit decimal tokens. Coordinate tokens are at most 127 bytes, must convert completely to a finite `double`, and must not overflow or underflow. Malformed, out-of-range, overlong, or embedded-NUL input ends the session after releasing the tree; a token is never split into multiple fields.

`rTree.asm` is a fixed four-point, single-leaf range-search demonstration. It inserts `(1,1)` through `(4,4)` and prints matches for `[2,2]`–`[3,3]`. It has no input, splitting, general rectangle insertion, or dynamic R-tree construction.

Build from this directory (outputs stay in `/tmp`):

```sh
gcc -std=c11 -Wall -Wextra "rTree.c" -o /tmp/rtrees
nasm -f elf64 "rTree.asm" -o /tmp/tree.o
gcc -no-pie /tmp/tree.o -o /tmp/tree-asm
```

## Introduction

**R-Tree** is a tree data structure designed for indexing multi-dimensional spatial data efficiently. Proposed by Antonin Guttman in 1984, it serves as a spatial access method that organizes geometric objects using their **Minimum Bounding Rectangles (MBRs)**.

### What Makes R-Trees Special?
- **Multi-dimensional indexing**: Unlike B-trees that handle 1D data, R-trees excel with 2D, 3D, and higher-dimensional spatial objects
- **Rectangle-based approximation**: Groups nearby objects within bounding rectangles for efficient spatial queries
- **Dynamic structure**: Supports insertions, deletions, and updates while maintaining balance
- **Query optimization**: Enables fast spatial queries like range searches, nearest neighbors, and intersection detection

---

## Structure Overview

### Basic Architecture

```
                    Root
                  /      \
               MBR A    MBR B
              /    \    /    \
          MBR1  MBR2  MBR3  MBR4
          (Leaf)(Leaf)(Leaf)(Leaf)
```

### Key Components

1. **Root Node**: Contains MBRs that encompass the largest spatial regions
2. **Internal Nodes**: Store MBRs of child nodes and pointers to subtrees
3. **Leaf Nodes**: Contain actual spatial objects with their MBRs and data pointers
4. **MBR (Minimum Bounding Rectangle)**: The smallest rectangle that completely encloses a spatial object or group of objects

### Node Structure

```c
typedef struct RTreeNode {
    bool is_leaf;           // Leaf or internal node flag
    int count;              // Number of entries in node
    Rectangle mbr[M];       // Array of MBRs
    union {
        struct RTreeNode *child[M];  // Child pointers (internal nodes)
        int data_id[M];              // Data identifiers (leaf nodes)
    };
} RTreeNode;
```

### Rectangle Representation

```c
typedef struct {
    double xmin, ymin;      // Bottom-left corner
    double xmax, ymax;      // Top-right corner
} Rectangle;
```

---

## Key Properties

### 1. **Balanced Structure**
- All leaf nodes are at the same depth
- Similar to B-trees, maintains logarithmic height
- Logarithmic height bounds one insertion path; overlapping MBRs can make a range search visit the entire tree

### 2. **Node Capacity Constraints**
- **Maximum entries (M)**: Four entries per node in the C implementation
- **Minimum entries (m)**: Usually M/2, ensures efficient space utilization
- **Root exception**: Root can have fewer than m entries

### 3. **MBR Properties**
- **Minimality**: Smallest rectangle containing all child objects
- **Enclosure**: All child MBRs must be completely contained within parent MBR
- **Overlap**: MBRs at the same level may overlap (unlike spatial partitioning methods)

### 4. **Dynamic Maintenance**
- Automatic rebalancing during insertions/deletions
- MBR adjustments propagate up the tree
- Split operations when nodes overflow

---

## Core Algorithms

### 1. **Search Algorithm**

```
Search(Node, QueryRect):
    if Node is leaf:
        for each entry in Node:
            if entry.MBR overlaps QueryRect:
                emit entry.data
    else:
        for each child in Node:
            if child.MBR overlaps QueryRect:
                Search(child, QueryRect)
```

**Time Complexity**: O(n) in the worst case. Overlapping bounds may require visiting every entry even when the query returns few matches; producing k matches also costs at least O(k).

### 2. **Insertion Algorithm**

#### Step 1: ChooseLeaf
```
ChooseLeaf(Node, NewRect):
    if Node is leaf:
        return Node
    else:
        // Select child requiring least MBR enlargement
        best_child = child with minimum area_enlargement(child.MBR, NewRect)
        return ChooseLeaf(best_child, NewRect)
```

#### Step 2: Insert and Split (if necessary)
```
InsertRecursive(Node, Rect, DataID):
    if Node is leaf:
        pending_entry = (Rect, DataID)
    else:
        child = entry requiring least MBR enlargement (break ties by area)
        sibling = InsertRecursive(child.node, Rect, DataID)
        child.MBR = bounds(child.node)  // Refresh even when no split occurs
        if sibling is absent:
            return no split
        pending_entry = (bounds(sibling), sibling)

    if Node has space:
        append pending_entry
        return no split
    else:
        redistribute all M + 1 entries into Node and a new sibling
        return new sibling

Insert(Tree, Rect, DataID):
    sibling = InsertRecursive(Tree.root, Rect, DataID)
    if sibling is present:
        Tree.root = new internal node covering the old root and sibling
```

#### Quadratic Split Algorithm
1. **Find Seeds**: Select two entries that waste the most area when grouped
2. **Initialize Groups**: Place seeds in separate groups
3. **Distribute Remaining**: Assign each remaining entry to the group requiring less enlargement, while ensuring each group can still reach the minimum occupancy `m`; leaf entries retain IDs and internal entries retain child pointers

### 3. **MBR Calculation**

```
CalculateMBR(Rectangles[]):
    xmin = min(all xmin values)
    ymin = min(all ymin values)
    xmax = max(all xmax values)
    ymax = max(all ymax values)
    return Rectangle(xmin, ymin, xmax, ymax)
```

### 4. **Overlap Detection**

```
Overlaps(Rect1, Rect2):
    return !(Rect1.xmax < Rect2.xmin ||
             Rect2.xmax < Rect1.xmin ||
             Rect1.ymax < Rect2.ymin ||
             Rect2.ymax < Rect1.ymin)
```

---

## Implementation Details

### Memory Management
- **Dynamic allocation**: Nodes created/destroyed as needed
- **Disk-based design**: Optimized for external storage
- **Page-oriented**: Each node fits within a disk page

### Insertion Strategy
1. **Least Enlargement**: Choose path minimizing MBR expansion
2. **Tie-breaking**: Prefer smaller existing MBRs
3. **Forced splitting**: When node capacity exceeded
4. **Tree adjustment**: Update MBRs along insertion path

### Split Policies
- **Quadratic Split**: O(M²) complexity, good quality splits
- **Linear Split**: O(M) complexity, faster but lower quality
- **Exponential Split**: O(2^M) complexity, optimal but impractical

---

## Use Cases and Applications

### 1. **Geographic Information Systems (GIS)**
```
Example: Find all restaurants within 2km of current location
Query: Range search with circular or rectangular boundary
Performance: Spatial pruning can reduce candidate checks; overlapping bounds may still require a full scan
```

### 2. **Computer-Aided Design (CAD)**
```
Example: Detect component overlaps in circuit layout
Query: Intersection detection between geometric shapes
Performance: Efficient collision detection in complex designs
```

### 3. **Spatial Databases**
```
Example: PostgreSQL PostGIS, Oracle Spatial
Usage: Index geometric columns for fast spatial queries
Integration: Native support in major database systems
```

### 4. **Game Development**
```
Example: Collision detection in 2D/3D games
Query: Find all objects intersecting player's bounding box
Performance: Real-time spatial queries for interactive applications
```

### 5. **Computer Vision**
```
Example: Image region indexing and retrieval
Usage: Index bounding boxes of detected objects
Application: Content-based image search systems
```

### 6. **Location-Based Services**
```
Example: Uber driver matching, Pokémon GO
Query: Nearest neighbor search for nearby entities
Scale: Handle millions of moving objects efficiently
```

---

## Performance Analysis

### Time Complexity

| Operation | Average Case | Worst Case | Best Case |
|-----------|--------------|------------|-----------|
| Range search | Depends on overlap and output | O(n) | O(1) if rejected at root |
| Insert    | O(log n), fixed M | O(log n), fixed M | O(1) in root leaf |
| Delete    | Not implemented | Not implemented | Not implemented |
| Split     | O(M²)        | O(M²)      | O(M²)     |

### Space Complexity
- **Storage**: O(n) where n = number of spatial objects
- **Node overhead**: Constant per node (MBR storage)
- **Minimum occupancy**: Two of four entries per non-root node in this implementation

### Performance Factors

#### Positive Factors
- **Clustered data**: Objects with spatial locality perform well
- **Balanced queries**: Range queries covering moderate areas
- **Appropriate M**: Node capacity tuned for disk page size

#### Negative Factors
- **Scattered data**: Random spatial distribution degrades performance
- **Large range queries**: May need to visit many nodes
- **High overlap**: Increases search paths and false positives

---

## Variants and Extensions

### 1. **R*-Tree (R-Star Tree)**
```
Improvements:
- Forced reinsertion before splitting
- Better split criteria (minimize overlap + area)
- Enhanced ChooseSubtree algorithm

Performance: Depends on data distribution, node capacity, and query workload
```

### 2. **R+-Tree (R-Plus Tree)**
```
Key Feature: No overlapping MBRs
Advantage: Unique search paths, better query performance
Disadvantage: More complex updates, potential data duplication
```

### 3. **Hilbert R-Tree**
```
Ordering: Uses Hilbert space-filling curve
Benefit: Better clustering of spatial objects
Application: Bulk loading and static datasets
```

### 4. **Priority R-Tree (PR-Tree)**
```
Guarantee: Worst-case optimal query performance
Query bound: O((N/B)^(1-1/d) + T/B) I/Os
Usage: Theoretical importance, practical in specific scenarios
```

### 5. **Time-Parameterized R-Tree (TPR-Tree)**
```
Extension: Handles moving objects
Dimensions: Spatial coordinates + velocity vectors
Application: Location tracking, mobile databases
```

---

## Code Example

### API Provided by `rTree.c`

The implementation exposes these operations (with the types declared earlier):

```c
RTree *create_rtree(void);
void insert_rect(RTree *tree, Rectangle rect, int data_id);
void search_range(RTreeNode *node, Rectangle query, int depth);
void display_tree(RTreeNode *node, int depth);
void free_rtree(RTreeNode *node);
```

`insert_rect` validates rectangle coordinates, calls `insert_rect_recursive`, and creates a new root when necessary. During recursion, each parent's covering MBR is refreshed after child insertion. A child split contributes its new sibling and MBR to the parent; splitting a full parent propagates the result upward. `quadratic_split` receives a pointer to the new sibling pointer, the pending rectangle, its data ID, and its child pointer (for an internal node). There is no separate `adjust_tree` operation.

`search_range` prints every entry whose rectangle inclusively overlaps the query. `free_rtree` accepts a node pointer and recursively releases that subtree; the owning `RTree` wrapper must be freed separately.

### Usage Example

This replaces the interactive `main` in `rTree.c`, using its existing types, function definitions, and standard-library includes:

```c
int main(void) {
    RTree *tree = create_rtree();

    insert_rect(tree, (Rectangle){0, 0, 5, 5}, 1);
    insert_rect(tree, (Rectangle){3, 3, 8, 8}, 2);
    insert_rect(tree, (Rectangle){6, 1, 9, 4}, 3);

    Rectangle query = {2, 2, 7, 7};
    printf("Objects overlapping query rectangle:\n");
    search_range(tree->root, query, 0);

    free_rtree(tree->root);
    free(tree);
    return 0;
}
```

---

## References

### Academic Papers
1. **Guttman, A. (1984)**. "R-Trees: A Dynamic Index Structure for Spatial Searching". *ACM SIGMOD International Conference on Management of Data*
2. **Beckmann, N., et al. (1990)**. "The R*-tree: An Efficient and Robust Access Method for Points and Rectangles". *ACM SIGMOD*
3. **Kamel, I. & Faloutsos, C. (1994)**. "Hilbert R-tree: An Improved R-tree using Fractals". *VLDB Conference*

### Modern Applications
- **PostGIS**: PostgreSQL spatial extension using R-tree indexing
- **Oracle Spatial**: Enterprise spatial database with R-tree support
- **MongoDB**: Geospatial queries using R-tree-like structures
- **Elasticsearch**: Geographic search with spatial indexing

### Implementation Resources
- **GEOS Library**: Open-source spatial operations library
- **Boost.Geometry**: C++ template library with R-tree implementation
- **Spatialite**: SQLite extension with R-tree spatial indexing

---

## Summary

R-Trees index spatial objects using hierarchical minimum bounding rectangles. Balanced height gives short insertion paths, while query performance depends on how many bounds overlap the search region. Range searches can visit every entry even when few objects match. The C example implements insertion and range search; deletion and updates are background concepts.

**Key Takeaways:**
- Efficient spatial indexing through hierarchical MBR organization
- Balanced height, with range-search work determined by overlap and output
- Wide applicability across spatial computing domains
- Multiple variants optimized for specific use cases
- Foundation for modern spatial database systems

The R-tree's enduring relevance in spatial computing demonstrates the power of well-designed data structures that capture the essential characteristics of their problem domain while remaining implementable and maintainable.
