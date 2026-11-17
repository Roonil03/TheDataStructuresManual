# Arrays:
An array is a collection of elements, typically of the same data type, stored in contiguous memory locations. Each element in the array can be accessed using an index, with the first element typically having an index of zero.

When an array is declared, a block of memory is allocated to hold its elements. The size of this memory block is determined by the number of elements in the array and the size of each element.<br>
Arrays store their elements in contiguous memory locations. This means that the memory addresses of the elements are sequential, with no gaps between them.

Accessing elements in an array is efficient due to its contiguous memory storage. The index of the element is used to calculate its memory address, allowing direct access in constant time, O(1).

### Examples in this directory

`array.c` reads and displays five signed C `int` values. `array.asm` stores and displays five digits from 0 through 9 in consecutive bytes. The assembly example targets Linux x86-64 and uses NASM with Linux system calls. Both examples accept whitespace-separated input and stop on missing or malformed values.
