# K‐D Trees

## Overview

A **K‐Dimensional Tree (KD‐Tree)** is a space‐partitioning binary tree data structure used for organizing points in k‐dimensional space. Each non‐leaf node acts as a hyperplane that divides the space into two half‐spaces, with points to the left and right of this hyperplane represented by the left and right subtrees respectively. The tree alternates splitting dimensions at each level, making it highly efficient for spatial queries such as nearest neighbor search and range queries.

## Key Properties

- **Binary Tree Structure**: Each node represents a k‐dimensional point, with every non‐leaf node having exactly two children.
- **Alternating Dimensions**: The splitting dimension cycles through all valid dimensions using the formula: *dimension = depth mod k*.
- **Space Partitioning**: Each internal node defines a hyperplane that divides the k‐dimensional space into two half‐spaces.
- **Balanced Construction**: When built optimally using median‐finding algorithms, the tree maintains logarithmic height for efficient operations.

## Core Operations

1. **Tree Construction**
   **Procedure**
   1. Let *points* ← input point set, *depth* ← 0.
   2. If *points* is empty, return NULL.
   3. Let *axis* ← *depth* mod *k*.
   4. Sort *points* by coordinate values along *axis*.
   5. Let *median* ← select median point from sorted *points*.
   6. Create node with *median* as splitting point.
   7. *node.left* ← recursively build tree(*points* before *median*, *depth* + 1).
   8. *node.right* ← recursively build tree(*points* after *median*, *depth* + 1).
   9. Return *node*.
   
   Time complexity: *O*(*n* log *n*) using efficient median‐finding algorithms.

2. **Nearest Neighbor Search**
   **Procedure**
   1. Let *best* ← first leaf reached by traversing tree toward query point.
   2. Let *best_distance* ← distance(*query*, *best*).
   3. Unwind recursion, checking each node:
      ```
      if distance(query, current_node) < best_distance then
          best ← current_node
          best_distance ← distance(query, current_node)
      if splitting_plane_distance < best_distance then
          recursively search other subtree
      ```
   4. Return *best*.
   
   Average time complexity: *O*(log *n*). Worst case: *O*(*n*).

3. **Range Query**
   **Procedure**
   1. Start at root with query rectangle *R*.
   2. For each node:
      ```
      if node.region completely outside R then
          return ∅
      if node.region completely inside R then  
          return all points in subtree
      if node.point ∈ R then
          add node.point to result
      recursively search left and right children
      ```
   3. Return collected points.
   
   Time complexity: *O*(*n*^(1−1/*k*) + *m*) where *m* is the number of reported points.

4. **Insertion**
   **Procedure**
   1. Traverse tree from root following comparison rules for each dimension.
   2. At each level *d*, compare point's coordinate along dimension *d* mod *k*.
   3. Go left if coordinate < node's coordinate, right otherwise.
   4. Insert as leaf when NULL position is reached.
   
   Time complexity: *O*(log *n*) for balanced trees.

5. **Deletion**
   **Procedure**
   1. Find node to delete.
   2. If leaf node, simply remove.
   3. If internal node:
      ```
      find replacement from appropriate subtree
      replace deleted node with replacement
      recursively delete replacement from subtree
      ```
   
   Time complexity: *O*(log *n*) amortized with periodic rebalancing.

## Complexity Analysis

| Operation | Average Case | Worst Case | Space |
| :-- | :-- | :-- | :-- |
| Construction | *O*(*n* log *n*) | *O*(*n* log²*n*) | *O*(*n*) |
| Nearest Neighbor | *O*(log *n*) | *O*(*n*) | *O*(1) |
| Range Query | *O*(*n*^(1−1/*k*) + *m*) | *O*(*n* + *m*) | *O*(1) |
| Insertion | *O*(log *n*) | *O*(*n*) | *O*(1) |
| Deletion | *O*(log *n*) | *O*(*n*) | *O*(1) |

## Implementation Details

- **Dimension Selection**: Use round‐robin cycling (*depth* mod *k*) or choose dimension with maximum variance for better balance.
- **Median Finding**: Linear‐time median‐of‐medians algorithm yields *O*(*n* log *n*) construction time vs. *O*(*n* log²*n*) when using *O*(*n* log *n*) sorting.
- **Distance Metrics**: Typically uses Euclidean distance, but supports other *L_p* norms and custom distance functions.
- **Memory Layout**: Store points directly in nodes or use index‐based references for large datasets.
- **Rebalancing**: Periodic reconstruction maintains performance as tree becomes unbalanced through dynamic operations.
- **High‐Dimensional Curse**: Performance degrades in high dimensions (*k* > 10) due to increased overlap between hyperrectangles during search operations.

## Applications

KD‐Trees are widely used across multiple domains for efficient spatial data management:

- **Nearest Neighbor Classification**: Accelerating k‐NN algorithms in machine learning and pattern recognition.
- **Computer Graphics**: Ray tracing acceleration, collision detection, and spatial partitioning in 3D rendering.
- **Geographic Information Systems**: Spatial queries, location‐based services, and geographic data analysis.
- **Computational Geometry**: Range searching, point location, and geometric algorithm optimization.
- **Robotics**: Path planning, obstacle avoidance, and sensor data processing.
- **Database Systems**: Multi‐dimensional indexing and spatial database query optimization.