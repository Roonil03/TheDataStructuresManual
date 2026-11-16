# Quad‐Tree Data Structure Documentation

## Included programs

The C and assembly examples read a count from 1 through 200, that many integer coordinate pairs, and one query point. They print a preorder traversal followed by a nearest point to the query.

Build from this directory (outputs stay in `/tmp`):

```sh
gcc -std=c11 -Wall -Wextra "QuadTree.c" -o /tmp/quadtree
nasm -f elf64 "QuadTree.asm" -o /tmp/tree.o
gcc -no-pie /tmp/tree.o -o /tmp/tree-asm
```

## Point insertion

Each node stores one point and four child links. Its x and y coordinates divide the plane into four quadrants. Insertion compares the incoming point to the current node, follows the selected child, and creates a node at the first empty link. Equal x goes east and equal y goes north. Identical points occupy separate nodes on the northeast path. The C and assembly programs reserve storage for 200 nodes.

Insertion takes O(h) time for tree height h. Input order determines the shape. A sequence following the same quadrant can produce a chain of n nodes, so building the tree can take O(n²) time. A traversal visits each point once and uses O(h) call-stack space.

## Nearest-point search

The examples compare the squared Euclidean distance from the query to every stored point. They keep the first point encountered at the smallest distance. The distance calculation accounts for the carry when adding the two squared coordinate differences, since two signed 32-bit points can have a squared distance larger than a 64-bit unsigned integer.

A query takes O(n) time and O(h) call-stack space. A region quadtree, used for tasks such as image subdivision, instead splits a fixed bounding box into four equal regions. Such a representation needs different insertion and search rules.

## Use Cases and Applications

- **Geographic Information Systems (GIS)**: Efficient spatial indexing of map features for rapid querying and rendering.
- **Computer Graphics**: Accelerating collision detection and view‐frustum culling by spatially partitioning geometry.
- **Image Processing**: Adaptive image compression and hierarchical representation of image regions.
- **Spatial Databases**: Indexing multi‐dimensional spatial records for fast range and nearest‐neighbor queries.
- **Game Development**: Real‐time spatial queries for object management, pathfinding, and occlusion culling.
