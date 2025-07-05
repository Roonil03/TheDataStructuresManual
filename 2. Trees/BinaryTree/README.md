# Binary Tree

## Overview

A Binary Tree is a hierarchical data structure where each node can have at most two children, referred to as the left child and right child. It is a fundamental data structure that forms the foundation for more specialized tree structures like Binary Search Trees, AVL Trees, and Expression Trees.

## Definition and Properties

### Basic Structure
- **Node**: Contains data and references to at most two child nodes
- **Root**: The topmost node of the tree
- **Leaf**: A node with no children
- **Internal Node**: A node with at least one child
- **Height**: The maximum number of edges from root to any leaf node
- **Depth**: The number of edges from root to a specific node

### Key Properties
1. **Maximum Children**: Each node can have at most 2 children
2. **Node Degree**: Maximum degree of any node is 3 (one parent + two children)
3. **Height Relationship**: For a tree with height h, minimum nodes = h+1, maximum nodes = 2^h - 1
4. **Leaf Nodes**: Number of leaf nodes = Number of nodes with 2 children + 1


## Algorithms and Operations

### Tree Traversal Algorithms

#### 1. Inorder Traversal (Left-Root-Right)
```
Algorithm:
1. Traverse left subtree
2. Visit root node
3. Traverse right subtree

Time Complexity: O(n)
Space Complexity: O(h) where h is height
```

#### 2. Preorder Traversal (Root-Left-Right)
```
Algorithm:
1. Visit root node
2. Traverse left subtree
3. Traverse right subtree

Use Cases: Tree copying, prefix expression evaluation
```

#### 3. Postorder Traversal (Left-Right-Root)
```
Algorithm:
1. Traverse left subtree
2. Traverse right subtree
3. Visit root node

Use Cases: Tree deletion, postfix expression evaluation
```

#### 4. Level Order Traversal (Breadth-First)
```
Algorithm:
1. Visit nodes level by level
2. Use queue for implementation

Time Complexity: O(n)
Space Complexity: O(w) where w is maximum width
```

### Basic Operations

#### Insertion
- Insert new nodes as leaf nodes
- Time Complexity: O(h) where h is height
- No specific order constraint in basic binary trees

#### Deletion
- Three cases: leaf node, node with one child, node with two children
- For nodes with two children, replace with inorder successor/predecessor

#### Search
- Linear search through traversal
- Time Complexity: O(n) in worst case

## Memory Representations

### 1. Linked Representation
```c
struct Node {
    int data;
    struct Node* left;
    struct Node* right;
};
```
- Dynamic allocation
- Memory efficient for sparse trees
- Pointer overhead

### 2. Array Representation
```
For node at index i:
- Left child at index: 2*i + 1
- Right child at index: 2*i + 2
- Parent at index: (i-1)/2
```
- Efficient for complete trees
- Cache-friendly access
- May waste space for incomplete trees

## Advantages

1. **Hierarchical Organization**: Natural representation of hierarchical data
2. **Efficient Traversal**: Multiple traversal options for different use cases
3. **Memory Efficiency**: Dynamic allocation, no pre-allocation required
4. **Recursive Structure**: Simplifies algorithm implementation
5. **Flexible Operations**: Easy insertion and deletion compared to arrays
6. **Cache Performance**: Array representation provides good cache locality

## Disadvantages

1. **No Ordering Guarantee**: Basic binary trees don't maintain sorted order
2. **Potential Imbalance**: Can degrade to linear structure (linked list)
3. **Memory Overhead**: Pointer storage in linked representation
4. **Search Efficiency**: O(n) search time in worst case
5. **Complexity**: More complex than linear data structures

## Time Complexity Summary

| Operation | Average Case | Worst Case | Best Case |
|-----------|--------------|------------|-----------|
| Search | O(n) | O(n) | O(1) |
| Insertion | O(h) | O(n) | O(1) |
| Deletion | O(h) | O(n) | O(1) |
| Traversal | O(n) | O(n) | O(n) |

Where h = height of tree, n = number of nodes

## Conclusion

Binary Trees provide a fundamental hierarchical data structure that forms the basis for many advanced tree structures. While they don't guarantee optimal search performance like specialized variants, their flexibility and simplicity make them valuable for representing hierarchical relationships, parsing expressions, and organizing data in tree-like structures. Understanding binary trees is essential for working with more complex tree-based data structures and algorithms.