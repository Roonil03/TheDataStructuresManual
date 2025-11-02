# HashSet

## Overview
A **HashSet** is a data structure that stores unique elements using a hash table with separate chaining for collision resolution. It provides O(1) average-case time complexity for insertion, deletion, and lookup operations.

## Data Structure

### HashSet Structure
```
HashSet (24 bytes):
├── buckets: Pointer to array of bucket heads (8 bytes)
├── capacity: Number of buckets (8 bytes)
└── size: Current number of elements (8 bytes)
```

### Node Structure (for Separate Chaining)
```
Node (16 bytes):
├── value: Integer value (8 bytes)
└── next: Pointer to next node (8 bytes)
```

### Hash Function
```
hash(value) = |value| % capacity
```

The hash function uses the modulo operation to map values to bucket indices. Negative values are converted to positive using absolute value.

## Operations

### Core Operations

1. **create_hashset(capacity)**
   - Initializes a new HashSet with specified capacity
   - Returns pointer to HashSet structure
   - Time Complexity: O(n) where n is capacity

2. **add(set, value)**
   - Adds an element to the HashSet
   - Rejects duplicates
   - Returns true if added, false if duplicate or error
   - Time Complexity: O(1) average, O(n) worst case

3. **contains(set, value)**
   - Checks if an element exists
   - Returns true if found, false otherwise
   - Time Complexity: O(1) average, O(n) worst case

4. **remove_element(set, value)**
   - Removes an element from the HashSet
   - Returns true if removed, false if not found
   - Time Complexity: O(1) average, O(n) worst case

5. **get_size(set)**
   - Returns the number of elements
   - Time Complexity: O(1)

6. **display(set)**
   - Prints all elements grouped by bucket
   - Time Complexity: O(n + m) where n is size and m is capacity

7. **clear_hashset(set)**
   - Removes all elements
   - Time Complexity: O(n + m)

8. **destroy(set)**
   - Frees all allocated memory
   - Time Complexity: O(n + m)

## Implementation Details

### Collision Resolution
The implementation uses **separate chaining**:
- Each bucket contains a linked list of nodes
- Colliding elements are added to the same bucket's linked list
- New nodes are inserted at the head for O(1) insertion

### Memory Management

**C Implementation:**
- Uses dynamic memory allocation (`malloc`/`free`)
- Proper cleanup with `destroy()` function

**Assembly Implementation:**
- Uses custom bump allocator (64KB static heap)
- No deallocation in simple allocator
- Pure assembly without C library dependencies

### Hash Distribution
With a good hash function and adequate capacity, elements distribute uniformly across buckets, maintaining O(1) average-case performance.

## Files

```
Hash-Based/HashSet/
├── hashset.c           # C implementation
├── hashset.asm         # NASM x86-64 assembly implementation
├── test_hashset.sh     # Test script for NASM
├── test_comparison.sh  # Comparison test script
└── README.md           # This file
```

## Compilation and Execution

### C Implementation

**Compile:**
```bash
gcc -o hashset_c hashset.c -Wall -Wextra
```

**Run:**
```bash
./hashset_c
```

### NASM Implementation

**Assemble:**
```bash
nasm -f elf64 hashset.asm -o hashset.o
```

**Link:**
```bash
gcc -nostdlib -static hashset.o -o hashset_asm
```

**Run:**
```bash
./hashset_asm
```

## Time and Space Complexity

### Time Complexity

| Operation | Average Case | Worst Case |
|-----------|-------------|-----------|
| add | O(1) | O(n) |
| contains | O(1) | O(n) |
| remove | O(1) | O(n) |
| get_size | O(1) | O(1) |
| display | O(n + m) | O(n + m) |
| clear | O(n + m) | O(n + m) |
| destroy | O(n + m) | O(n + m) |

*n = number of elements, m = capacity*

**Worst case** occurs when all elements hash to the same bucket (poor hash function or unfortunate data distribution).

### Space Complexity

- **Total Space:** O(n + m)
  - n for storing elements
  - m for bucket array

- **Per Element:** 16 bytes (Node) + amortized bucket overhead

## Applications

1. **Duplicate Detection**
   - Remove duplicates from datasets
   - Check for unique values

2. **Membership Testing**
   - Fast lookup operations
   - Set membership queries

3. **Caching**
   - Store unique cache keys
   - Deduplicate cache entries

4. **Database Indexing**
   - Fast retrieval of records
   - Unique constraint enforcement

5. **Compiler Symbol Tables**
   - Store variable names
   - Check for redeclarations

6. **Graph Algorithms**
   - Track visited nodes
   - Store edge sets

## Advantages and Disadvantages

### Advantages ✓

1. **Fast Operations:** O(1) average-case for add, remove, contains
2. **Uniqueness:** Automatically enforces unique elements
3. **Simple Interface:** Easy to use and understand
4. **Memory Efficient:** No duplicate storage
5. **Flexible Size:** Can accommodate varying numbers of elements

### Disadvantages ✗

1. **No Ordering:** Elements are not stored in any particular order
2. **Worst Case:** O(n) performance when many collisions occur
3. **Fixed Capacity:** Current implementation doesn't auto-resize
4. **Hash Function Dependency:** Performance relies on good hash function
5. **Memory Overhead:** Requires extra space for bucket array and pointers

## Comparison with Similar Structures

| Feature | HashSet | HashMap | HashTable |
|---------|---------|---------|-----------|
| Storage | Values only | Key-value pairs | Key-value pairs |
| Duplicates | No | Keys: No, Values: Yes | Keys: No, Values: Yes |
| Ordering | No | No | No |
| Null Support | Yes (C impl) | Yes (keys & values) | No |
| Thread Safety | No | No | Yes |
| Use Case | Unique values | Key lookups | Concurrent access |

## Optimization Opportunities

1. **Dynamic Resizing**
   - Implement automatic rehashing when load factor > 0.75
   - Double capacity when threshold exceeded

2. **Better Hash Function**
   - Use multiplication-based hashing
   - Implement universal hashing

3. **Load Factor Tracking**
   - Monitor load factor = size / capacity
   - Trigger resize when appropriate

4. **Cache Optimization**
   - Keep bucket array contiguous for cache locality
   - Consider open addressing for better cache performance
