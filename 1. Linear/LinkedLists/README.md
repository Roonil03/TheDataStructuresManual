# Linked Lists
A linked list is a dynamic data structure where elements (nodes) are connected through pointers/references. Unlike arrays, linked lists don't require contiguous memory allocation.

This structure provides flexibility in data management but requires careful pointer handling to prevent memory leaks and maintain list integrity.

### Singly Linked List

- Each node points to the next node
- Last node points to NULL
- Structure: `Node → Node → Node → NULL`
- Uses one link per node, fewer than a doubly linked list
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
- Maintains both forward and backward circular links
- Allows traversal in both directions without NULL endpoints

### Examples in this directory

The C examples implement a doubly linked list (`doublylinkedList.c`) and a circular singly linked list (`circularSingleLinkedList.c`). They support append, deletion of the first matching value, and forward display. Append searches for the tail in the doubly linked example, so it costs O(n); the circular singly linked example retains its tail and appends in O(1). Deletion searches in O(n). Both release their nodes on exit, end of input, or malformed input.

The Linux x86-64 NASM examples implement singly, doubly, and circular doubly linked lists. They support append and display; the doubly linked examples display in both directions. The assembly examples accept one digit (0–9) per whitespace-separated token and stop on malformed input or EOF. Each node is allocated with `mmap`; the kernel releases live mappings when the process exits. C examples accept signed `int` values.
