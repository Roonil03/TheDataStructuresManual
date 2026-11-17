# Hash set

The set stores each integer once. Each bucket points to a chain of nodes. The bucket index is the magnitude of the remainder modulo the positive bucket count. Adding a duplicate or removing a missing value returns false.

## Representation

The C version stores an `int` in each node. On x86-64 its header takes 16 bytes for the bucket pointer, capacity and size. A node takes 16 bytes including padding. Removal frees a node, clearing frees all nodes, and destruction also frees the buckets and header.

The Linux x86-64 assembly example uses 64-bit integers. Its header takes 24 bytes and each node takes 16 bytes. The header, buckets and nodes share a 64 KiB bump allocator. Removing or clearing entries detaches them. Arena storage lasts for the process lifetime, so repeated insertions can exhaust the arena even when the live set is small.

## Operations

For n values and b buckets, membership, insertion and removal take O(1 + n / b) expected time under uniform hashing and O(n) in the worst case. Reading the size takes O(1). Showing all buckets or clearing the set takes O(b + n). Neither implementation resizes the bucket array.

## Run on Linux x86-64

```sh
gcc -std=c11 -Wall -Wextra hashset.c -o /tmp/hashset-c
/tmp/hashset-c
nasm -f elf64 hashset.asm -o /tmp/hashset.o
ld /tmp/hashset.o -o /tmp/hashset-asm
/tmp/hashset-asm
```
