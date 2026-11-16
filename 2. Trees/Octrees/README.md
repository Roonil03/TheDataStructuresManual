# Octree Documentation

## Included programs

Both programs offer menu choices 1 (insert), 2 (search), 3 (display), and 4 (exit), with integer coordinates restricted to 0–255. Multiple distinct points remain searchable and duplicate insertion does not add a second point. The C version recursively subdivides inclusive bounding boxes, allocates all valid children when splitting an occupied leaf, and stores explicit leaf occupancy. The standalone Linux NASM version is a sparse, eight-level coordinate-bit trie: each level consumes one bit from each coordinate, from most significant to least significant. Its 80-byte nodes come from zeroed 4096-byte anonymous mappings, with a bump pointer packing 51 nodes into each mapping. Each lookup traverses at most eight subdivision levels for this fixed domain. Display order/format differs between versions. The C program frees its nodes on exit; Linux reclaims the assembly program's mappings on exit. Deletion, range queries, and dynamic-domain operations below are background concepts.

Ordinary EOF while waiting for a menu choice exits both programs with status 0. A malformed or out-of-range integer token at that prompt makes `octree.c` write a diagnostic to stderr, free the tree, and return status 0; `octree.asm` exits with status 1. After insert or search has been selected, malformed input or EOF before all three coordinates have arrived returns status 1 in both programs. A valid integer menu choice outside 1–4 ends the C session with status 0, while the NASM menu prompts again.

Build from this directory (outputs stay in `/tmp`):

```sh
gcc -std=c11 -Wall -Wextra "octree.c" -o /tmp/octrees
nasm -f elf64 octree.asm -o /tmp/octree.o
ld /tmp/octree.o -o /tmp/octree-asm
```

## Overview
An **Octree** partitions three-dimensional space by recursively splitting a region along its three coordinate axes into up to eight octants. Regions are usually cubes, though the C implementation also accepts inclusive, axis-aligned integer boxes. It is the 3D analog of a quadtree in 2D or recursive interval bisection in 1D. Octrees are useful in 3D graphics, spatial indexing, collision detection, and scientific computing applications.

## Structure
Each node represents a region of 3D space and can either be:
- **Leaf Node**: Contains a point or is empty in these programs; other variants store buckets or volumetric data
- **Internal Node**: Has up to 8 children representing the 8 octants

### Octant Organization
These programs use bits 0, 1, and 2 for the high x, y, and z halves respectively. Direction names depend on the application's coordinate convention:
```
Octant 0: TopLeftFront      (x≤mid, y≤mid, z≤mid)
Octant 1: TopRightFront     (x>mid, y≤mid, z≤mid)
Octant 2: BottomLeftFront   (x≤mid, y>mid, z≤mid)
Octant 3: BottomRightFront  (x>mid, y>mid, z≤mid)
Octant 4: TopLeftBottom     (x≤mid, y≤mid, z>mid)
Octant 5: TopRightBottom    (x>mid, y≤mid, z>mid)
Octant 6: BottomLeftBack    (x≤mid, y>mid, z>mid)
Octant 7: BottomRightBack   (x>mid, y>mid, z>mid)
```

## Key Operations

Let **h** be tree height, **m** the number of allocated nodes, and **n** the number of stored points. Exact lookup and insertion in these point trees follow one path and take O(h); h depends on coordinate precision and the subdivision policy, not just n. Here h ≤ 8, so these operations have a fixed bound. Display visits all allocated nodes in O(m) time with O(h) recursive stack space; node storage is O(m). A roughly uniform point distribution can give h = O(log n) before reaching the precision limit, but arbitrary octrees do not guarantee this bound.

### 1. Insertion
- **Time Complexity**: O(h), with constant-size child allocation per subdivision
- **Process**:
  1. Check if point is within node boundaries
  2. If leaf node is empty, store the point
  3. If a leaf contains a different point, subdivide and retain the old point
  4. Recursively insert into appropriate octant

The assembly version instead allocates missing nodes along the point's eight-level path, then marks the final node occupied.

### 2. Exact Search
- **Time Complexity**: O(h)
- **Process**:
  1. Check if point is within current node boundaries
  2. If leaf node, check for exact match
  3. If internal node, determine octant and recurse

### 3. Range Query
- **Time Complexity**: O(v + k), where v is the number of visited nodes and k is the number of reported points; O(m + k) in the worst case
- **Process**: Traverse only octants that intersect with query region

### 4. Deletion
- **Time Complexity**: O(h) for exact removal and constant work per ancestor when merging
- **Process**: Find and remove point, potentially merging nodes if they become sparse

## Implementation Details

### Node Structure
```c
typedef struct OctreeNode {
    bool is_leaf;
    bool occupied;
    Point point;              // Only valid if is_leaf && occupied
    Point min_bound, max_bound;
    struct OctreeNode* children[8];
} OctreeNode;
```

### Octant Calculation
```c
int calculate_octant(int x, int y, int z, int midx, int midy, int midz) {
    int octant = 0;
    if (x > midx) octant |= 1;  // Right half
    if (y > midy) octant |= 2;  // High y half
    if (z > midz) octant |= 4;  // High z half
    return octant;
}
```

## Advantages
- **Spatial Pruning**: Range and nearest-neighbor algorithms can skip irrelevant regions
- **Adaptive Resolution**: Higher resolution where data is dense
- **Adaptive Storage**: Empty regions need not be refined; child allocation policies determine memory overhead
- **Scalable**: Can handle large 3D datasets when depth and allocation overhead are controlled
- **Natural 3D Partitioning**: Intuitive spatial organization

## Disadvantages
- **Memory Overhead**: Requires additional pointers for tree structure
- **Degeneracy Issues**: Poor performance with clustered or aligned data
- **Construction Cost**: Building tree can be expensive for dynamic datasets
- **Cache Performance**: Random access patterns can be cache-unfriendly

## Applications

### Computer Graphics
- **Level-of-Detail (LOD)**: Rendering optimization based on distance
- **Frustum Culling**: Skip rendering objects outside view
- **Ray Tracing**: Accelerate ray-object intersection tests
- **Collision Detection**: Efficient broad-phase collision detection

### Scientific Computing
- **N-body Simulation**: Gravitational or electromagnetic simulations
- **Finite Element Analysis**: Mesh refinement and partitioning
- **Volume Rendering**: Medical imaging and visualization
- **Fluid Dynamics**: Adaptive mesh refinement

### Gaming and Simulation
- **World Partitioning**: Divide game world for efficient processing
- **Physics Simulation**: Broad-phase collision detection
- **AI Pathfinding**: Hierarchical spatial reasoning
- **Sound Propagation**: 3D audio occlusion and attenuation

### Geospatial Applications
- **GIS Systems**: Spatial indexing of geographic data
- **Point Cloud Processing**: LiDAR and 3D scanning data
- **Urban Planning**: Building and infrastructure modeling
- **Environmental Modeling**: Climate and weather simulation

## Variants and Extensions

### Linear Octree
- **Description**: Array-based representation using Morton codes
- **Advantage**: Better cache locality, simpler memory management
- **Use Case**: Static datasets, GPU implementations

### Loose Octree
- **Description**: Octants overlap to reduce object migration
- **Advantage**: More stable for moving objects
- **Use Case**: Dynamic simulations, game engines

### Compressed Octree
- **Description**: Compress paths with only one nonempty child
- **Advantage**: Reduced memory usage for sparse data
- **Use Case**: Large-scale volumetric data

### Multi-level Octree
- **Description**: Hybrid approach with different subdivision strategies
- **Advantage**: Optimized for specific data distributions
- **Use Case**: Complex scientific simulations

## Performance Considerations

### Best Case Scenarios
- **Uniformly Distributed Data**: Often shallow occupied paths, with O(log n) depth before the precision limit
- **Selective Range Queries**: Can visit far fewer nodes than a full traversal
- **Static Data**: No rebalancing overhead

### Worst Case Scenarios
- **Highly Clustered Data**: Can require deep paths in general; the included programs remain bounded to eight levels
- **Frequent Updates**: Expensive tree restructuring
- **Very Sparse Data**: High memory overhead relative to data

### Optimization Techniques
- **Lazy Deletion**: Mark nodes as deleted without restructuring
- **Bulk Loading**: Process points in spatial or Morton order to improve locality and batch construction
- **Memory Pooling**: Pre-allocate nodes to reduce allocation overhead
- **Parallel Construction**: Utilize multiple cores for tree building

## Comparison with Other Spatial Data Structures

| Structure | Dimensions | Space Partition | Query Bounds | Best Use Case |
|-----------|------------|-----------------|------------|---------------|
| Balanced binary search tree | 1D | Ordered keys | O(log n) exact lookup; O(log n + k) range reporting | Ordered 1D data |
| Quadtree | 2D | 4-way split | O(h) point location; range cost depends on visited nodes | 2D spatial data |
| **Octree** | **3D** | **8-way split** | **O(h) exact lookup; O(v + k) range reporting** | **3D applications** |
| R-tree | Any | Potentially overlapping bounding boxes | O(n + k) worst-case spatial query | Objects with spatial extent |
| Grid | Any | Fixed cells | O(1) indexed cell access; query cost depends on cells and candidates examined | Uniform density |
| BSP Tree | Any | Arbitrary splitting planes | O(h) point location; spatial queries may visit many regions | 3D rendering |

## Implementation Tips

### Memory Management
```c
// Use memory pools for efficient allocation
typedef struct NodePool {
    OctreeNode nodes[POOL_SIZE];
    int next_free;
} NodePool;
```

### Boundary Handling
```c
// Always validate bounds before operations
bool is_within_bounds(Point p, Point min_b, Point max_b) {
    return p.x >= min_b.x && p.x <= max_b.x &&
           p.y >= min_b.y && p.y <= max_b.y &&
           p.z >= min_b.z && p.z <= max_b.z;
}
```

### Subdivision Strategy
```c
// Inclusive integer bounds: split if at least one axis has two values.
// Compare endpoints directly, avoiding overflow from signed subtraction.
bool should_subdivide(Point min_b, Point max_b) {
    if (min_b.x > max_b.x || min_b.y > max_b.y || min_b.z > max_b.z)
        return false;
    return min_b.x < max_b.x ||
           min_b.y < max_b.y ||
           min_b.z < max_b.z;
}
```

When splitting a box, omit high-half children for axes whose minimum equals their maximum, as `octree_subdivide` does. Compute midpoints with widened arithmetic: `min + ((long long)max - min) / 2` for these 32-bit integer coordinates.


## Conclusion
Octrees organize 3D data at adaptive spatial resolutions. Their performance depends on tree height, coordinate precision, node allocation, and how many regions a query visits. The included programs demonstrate bounded exact lookup, insertion, and display over 0–255 coordinates; broader spatial operations require additional algorithms.

The key to successful octree implementation lies in understanding the specific requirements of your application and choosing appropriate optimization strategies. Whether used for collision detection in games, ray tracing in graphics, or spatial analysis in scientific computing, octrees remain a fundamental tool in the computer scientist's toolkit for managing three-dimensional data efficiently.
