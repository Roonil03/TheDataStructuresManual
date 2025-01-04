# Linked Lists
A linked list is a dynamic data structure where elements (nodes) are connected through pointers/references. Unlike arrays, linked lists don't require contiguous memory allocation.

This structure provides flexibility in data management but requires careful pointer handling to prevent memory leaks and maintain list integrity.

### Singly Linked List

- Each node points to the next node
- Last node points to NULL
- Structure: `Node → Node → Node → NULL`
- Memory efficiency: Best
- Only forward traversal possible
### Doubly Linked List

- Each node points to both next and previous nodes
- Structure: `NULL ↔ Node ↔ Node ↔ Node ↔ NULL`
- Uses more memory due to extra pointer
- Allows bidirectional traversal
- Easier deletion operations
### Circular Singly Linked List

- Similar to singly linked list
- Last node points back to first node
- Structure: `Node → Node → Node ↻`
- Useful for circular operations
- No NULL termination
### Circular Doubly Linked List

- Combines features of doubly linked and circular lists
- Structure: `Node ↔ Node ↔ Node ↻`
- Most complex implementation
- Most flexible for operations