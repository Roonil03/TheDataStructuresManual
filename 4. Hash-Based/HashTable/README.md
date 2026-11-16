# Hash table

The C and Linux x86-64 assembly examples use linear probing in a fixed array of 16 slots. Each slot holds a 64-bit unsigned key and a 64-bit unsigned value, for 256 bytes of entry storage. The C table also tracks its live entry count.

## Probing

The first slot for a key is `key % 16`. A collision moves the probe to the next slot, wrapping at the end of the array. Deletion leaves a tombstone so keys farther along the probe sequence remain reachable. Insertion remembers the first tombstone and keeps looking for an existing key before reusing it. Updating an existing key succeeds even in a full table.

Two key values are reserved. `UINT64_MAX` marks an empty slot and `UINT64_MAX - 1` marks a deleted slot. Initialize the table with `init_table` before accessing it.

| Operation | Result |
| --- | --- |
| Insert or update | 0 on success, 1 for a reserved key or a full table with a new key |
| Search | Stored value on a hit, `UINT64_MAX` on a miss |
| Delete | 0 if removed, 1 if absent |

The search return value alone cannot distinguish a stored `UINT64_MAX` value from a miss. Lookup, insertion and deletion take expected O(1) time at low load under uniform hashing. Each examines at most the table capacity in the worst case.

## Run on Linux x86-64

```sh
gcc -std=c11 -Wall -Wextra hashtable.c -o /tmp/hashtable-c
/tmp/hashtable-c
nasm -f elf64 hashtable.asm -o /tmp/hashtable.o
ld /tmp/hashtable.o -o /tmp/hashtable-asm
/tmp/hashtable-asm
```
