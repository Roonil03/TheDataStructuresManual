# Hash Table

## Overview

A **Hash Table** is a data structure that implements an associative array—a structure that maps keys to values. It uses a **hash function** to compute an index into an array of buckets or slots, from which the desired value can be found. This implementation uses **linear probing** for collision resolution, making it highly efficient for insertion, deletion, and lookup operations.

### Key Characteristics

- **Structure**: Fixed-size array-based hash table with entries
- **Collision Resolution**: Linear probing
- **Key/Value Size**: 64-bit each (supports both integers and pointers)
- **Time Complexity**: 
  - Average: O(1) for insert, search, delete
  - Worst case: O(n) when load factor is high
- **Space Complexity**: O(n) for storing n elements

## Implemented Operations

### 1. **Initialization** - `init_table()`
Prepares the hash table by marking all slots as empty.

```c
void init_table(void)
```

**Time Complexity**: O(n) where n = TABLE_SIZE

**Example**:
```c
init_table();  // All 16 slots marked as EMPTY_KEY (0xFFFFFFFFFFFFFFFF)
```

---

### 2. **Insertion** - `insert(key, value)`
Inserts a key-value pair into the hash table with linear probing collision handling.

```c
int insert(uint64_t key, uint64_t value)
```

**Parameters**:
- `key`: 64-bit unsigned integer key
- `value`: 64-bit unsigned integer value

**Returns**:
- `0`: Success
- `1`: Failure (table full)

**Collision Handling**: If a slot is occupied, probes the next slot sequentially: (hash + 1) % TABLE_SIZE, (hash + 2) % TABLE_SIZE, etc.

**Time Complexity**: O(1) average, O(n) worst case

**Example**:
```c
insert(42, 100);   // Insert key=42, value=100
insert(15, 200);   // Insert key=15, value=200
```

---

### 3. **Search** - `search(key)`
Retrieves the value associated with a given key.

```c
uint64_t search(uint64_t key)
```

**Parameters**:
- `key`: 64-bit unsigned integer key to search

**Returns**:
- Value associated with the key if found
- `-1` (0xFFFFFFFFFFFFFFFF) if not found

**Time Complexity**: O(1) average, O(n) worst case

**Example**:
```c
uint64_t value = search(42);
if (value == (uint64_t)-1) {
    printf("Key not found\n");
} else {
    printf("Found value: %llu\n", (unsigned long long)value);
}
```

---

### 4. **Deletion** - `delete_key(key)`
Removes a key-value pair from the hash table using tombstone marking.

```c
int delete_key(uint64_t key)
```

**Parameters**:
- `key`: 64-bit unsigned integer key to delete

**Returns**:
- `0`: Success
- `1`: Key not found

**Tombstone Approach**: Marks deleted entries with DELETED_KEY (0xFFFFFFFFFFFFFFFE) rather than removing them, preserving linear probe sequences.

**Time Complexity**: O(1) average, O(n) worst case

**Example**:
```c
if (delete_key(42) == 0) {
    printf("Successfully deleted key=42\n");
} else {
    printf("Key not found\n");
}
```

---

### 5. **Hash Function** - `hash_function(key)`
Computes the initial hash index for a given key.

```c
uint64_t hash_function(uint64_t key)
```

**Formula**: `hash = key % TABLE_SIZE`

**Time Complexity**: O(1)

**Example**:
```c
uint64_t index = hash_function(97);  // Returns 97 % 16 = 1
```

---

## Implementation Details

### Memory Layout

Each hash table entry is **16 bytes**:
- **8 bytes**: Key (uint64_t)
- **8 bytes**: Value (uint64_t)

```
Hash Table (256 bytes for TABLE_SIZE=16):
┌──────────────────────┬──────────────────────┐
│ Slot 0               │ [Key | Value]        │  16 bytes
├──────────────────────┼──────────────────────┤
│ Slot 1               │ [Key | Value]        │  16 bytes
├──────────────────────┼──────────────────────┤
│ ...                  │ ...                  │  ...
├──────────────────────┼──────────────────────┤
│ Slot 15              │ [Key | Value]        │  16 bytes
└──────────────────────┴──────────────────────┘
```

### Special Key Values

- **EMPTY_KEY** (0xFFFFFFFFFFFFFFFF): Indicates an unoccupied slot
- **DELETED_KEY** (0xFFFFFFFFFFFFFFFE): Indicates a tombstone (deleted) slot

### Linear Probing Algorithm

When inserting or searching:

1. Compute hash index: `hash_index = key % TABLE_SIZE`
2. Check slot at `hash_index`
3. If slot is empty or deleted, insert/conclude
4. If occupied and key doesn't match, probe next: `(hash_index + probe_count) % TABLE_SIZE`
5. Repeat until finding a suitable slot or traversing entire table

### Collision Example

```
Insert key=42:    hash(42) = 42 % 16 = 10  →  Stored at slot 10
Insert key=58:    hash(58) = 58 % 16 = 10  →  Collision!
                  Probe slot 11  →  Empty  →  Stored at slot 11
Insert key=74:    hash(74) = 74 % 16 = 10  →  Collision!
                  Probe slot 11  →  Occupied
                  Probe slot 12  →  Empty  →  Stored at slot 12
```

## File Structure

| File | Description |
|------|-------------|
| `hashtable.c` | C implementation (equivalent to NASM assembly) |
| `hashtable.asm` | x86-64 NASM assembly implementation |
| `test.sh` | Comprehensive build and test script |
| `README.md` | This file |


## Performance Analysis

### Load Factor Impact

Load Factor = (Number of Entries) / TABLE_SIZE

| Load Factor | Avg Probes | Worst Case | Status |
|------------|-----------|-----------|---------|
| 25% | ~1 | 1 | Excellent |
| 50% | ~1-2 | 5 | Good |
| 75% | ~2-3 | 10 | Fair |
| 90% | 5+ | 16 | Poor |

With TABLE_SIZE = 16:
- Optimal: up to 8 entries
- Acceptable: up to 12 entries
- Degraded: more than 12 entries

### Time Complexity

| Operation | Average | Worst Case |
|-----------|---------|-----------|
| Insert | O(1) | O(n) |
| Search | O(1) | O(n) |
| Delete | O(1) | O(n) |
| Hash function | O(1) | O(1) |

### Space Complexity

- **Total**: O(n × ENTRY_SIZE) = O(n) where n = TABLE_SIZE
- **Fixed**: 256 bytes for TABLE_SIZE=16
- **Per element**: 16 bytes


## Advantages of Linear Probing

✓ Good cache locality (sequential memory access)
✓ Simple implementation
✓ Low memory overhead
✓ Efficient for reasonable load factors
✓ Deterministic probing sequence

## Disadvantages of Linear Probing

✗ Primary clustering (large blocks of occupied slots)
✗ Performance degrades rapidly at high load factors
✗ May probe many slots for unsuccessful searches

## Improvements and Optimizations

### Possible Enhancements

1. **Dynamic Resizing**: Automatically rehash when load factor exceeds threshold
2. **Better Hash Function**: Use FNV-1a or MurmurHash for better distribution
3. **Quadratic Probing**: Reduce clustering: `(hash + i²) % TABLE_SIZE`
4. **Double Hashing**: Use secondary hash: `(hash1 + i × hash2) % TABLE_SIZE`
5. **Cuckoo Hashing**: Multiple hash tables with guaranteed O(1) worst case
6. **Generic Entries**: Support variable-size keys and values
7. **Iterator Support**: Traverse all entries
8. **Statistics**: Track collision counts and probe depths

## Comparison: HashSet vs HashMap vs Hashtable

| Feature | HashSet | HashMap | Hashtable |
|---------|---------|---------|-----------|
| **Stores** | Unique values | Key-value pairs | Key-value pairs |
| **Duplicates** | Not allowed | No duplicate keys | No duplicate keys |
| **Null Keys** | One null | One null | No null |
| **Null Values** | One null | Multiple null | No null |
| **Synchronized** | No | No | Yes |
| **Performance** | Faster | Faster | Slower |
| **Internal Use** | HashMap | Hash table | N/A |
