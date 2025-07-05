# Binary Search Tree (BST)

## Overview

A Binary Search Tree (BST) is a specialized binary tree data structure that maintains a specific ordering property: for any node, all values in the left subtree are less than the node's value, and all values in the right subtree are greater than the node's value. This ordering enables efficient searching, insertion, and deletion operations.

## Definition and Properties

### BST Property
For every node X in the tree:
- **Left Subtree**: All nodes have values < X.value
- **Right Subtree**: All nodes have values > X.value
- **Recursively Applied**: Both left and right subtrees are also BSTs
- **Unique Values**: Typically no duplicate values allowed

### Key Characteristics
- **Ordered Structure**: Maintains sorted order of elements
- **Binary Property**: Each node has at most two children
- **Search Efficiency**: Enables binary search on tree structure
- **Dynamic Size**: Grows and shrinks dynamically with insertions/deletions

## Algorithms and Operations

### 1. Search Operation
```
Algorithm:
1. Start at root node
2. If target == current node value, return node
3. If target < current node value, search left subtree
4. If target > current node value, search right subtree
5. If node is NULL, value not found

Time Complexity: O(h) where h is height
- Best Case: O(log n) for balanced tree
- Worst Case: O(n) for skewed tree
```

### 2. Insertion Operation
```
Algorithm:
1. Start at root node
2. If tree is empty, create new root
3. If value < current node, go to left subtree
4. If value > current node, go to right subtree
5. Insert at first NULL position found
6. New nodes always inserted as leaves

Time Complexity: O(h)
Space Complexity: O(h) for recursive implementation
```

### 3. Deletion Operation
Three cases to handle:

#### Case 1: Node is a Leaf
- Simply remove the node
- Update parent's pointer to NULL

#### Case 2: Node has One Child
- Replace node with its child
- Connect parent directly to child

#### Case 3: Node has Two Children
- Find inorder successor (smallest node in right subtree)
- Replace node's value with successor's value
- Delete the successor node

```
Time Complexity: O(h)
Space Complexity: O(h) for recursive implementation
```

### 4. Traversal Operations

#### Inorder Traversal (Left-Root-Right)
```
Algorithm:
1. Traverse left subtree
2. Visit current node
3. Traverse right subtree

Result: Nodes visited in sorted order
Time Complexity: O(n)
```

#### Preorder Traversal (Root-Left-Right)
- Used for tree copying and serialization

#### Postorder Traversal (Left-Right-Root)
- Used for tree deletion and cleanup

#### Level Order Traversal
- Breadth-first traversal using queue

### 5. Additional Operations

#### Find Minimum
```
Algorithm:
Keep going left until leftmost node
Time Complexity: O(h)
```

#### Find Maximum
```
Algorithm:
Keep going right until rightmost node
Time Complexity: O(h)
```

#### Find Successor
```
Algorithm:
1. If node has right subtree, return minimum of right subtree
2. Otherwise, go up until we find ancestor where node is in left subtree
Time Complexity: O(h)
```

## Advantages

1. **Efficient Operations**: O(log n) average time for search, insert, delete
2. **Ordered Data**: Maintains sorted order automatically
3. **Range Queries**: Efficient retrieval of elements in a range
4. **Dynamic Size**: Grows and shrinks as needed
5. **Memory Efficient**: No pre-allocation required
6. **Recursive Structure**: Simplifies algorithm implementation
7. **Sorted Traversal**: Inorder traversal gives sorted sequence

## Disadvantages

1. **Balance Dependency**: Performance degrades with unbalanced trees
2. **No Constant Time**: No O(1) operations like hash tables
3. **Memory Overhead**: Pointer storage overhead
4. **Complexity**: More complex than arrays and linked lists
5. **Cache Performance**: Not as cache-friendly as arrays
6. **Balancing Cost**: Self-balancing variants require additional operations

## Time Complexity Summary

| Operation | Average Case | Worst Case | Best Case |
|-----------|--------------|------------|-----------|
| Search | O(log n) | O(n) | O(1) |
| Insertion | O(log n) | O(n) | O(1) |
| Deletion | O(log n) | O(n) | O(log n) |
| Inorder Traversal | O(n) | O(n) | O(n) |
| Find Min/Max | O(log n) | O(n) | O(1) |

## Space Complexity
- **Storage**: O(n) for n nodes
- **Recursive Operations**: O(h) stack space where h is height
- **Iterative Operations**: O(1) additional space


## Conclusion

Binary Search Trees provide an excellent balance between search efficiency and dynamic operations. While basic BSTs can suffer from balance issues, their self-balancing variants ensure consistent O(log n) performance. BSTs are fundamental to many applications requiring efficient searching, sorting, and range queries. Understanding BSTs is crucial for database design, algorithm optimization, and building efficient software systems that handle dynamic sorted data.